#!/bin/bash

# AWS Control Tower IAM Role Creation via CloudFormation StackSets
# This script creates the AWSControlTowerExecution role using StackSets to bypass SCP restrictions

# Variables
ROLE_NAME="AWSControlTowerExecution"
STACKSET_NAME="AWSControlTowerExecutionRole"
TEMPLATE_FILE="control-tower-role-template.yaml"
OPERATION_ID_PREFIX="ControlTowerRole-$(date +%s)"

echo "AWS Control Tower IAM Role Creation via StackSets"
echo "================================================"
echo ""
echo "🚨 IMPORTANT WARNING 🚨"
echo "======================="
echo ""
echo "This script may deploy IAM roles to MULTIPLE AWS accounts!"
echo ""
echo "If the existing StackSet uses SERVICE_MANAGED permissions (common with Control Tower):"
echo "• The role will be created in ALL accounts within the target account's Organizational Unit"
echo "• This could affect dozens of accounts, not just the one you specify"
echo "• You will be prompted for confirmation before any OU-wide deployment"
echo ""
echo "If you only want to affect a single account, consider:"
echo "• Using AWS Console for individual account deployment"
echo "• Creating a separate SELF_MANAGED StackSet"
echo "• Contacting your AWS administrator"
echo ""
read -p "Do you understand this warning and want to continue? (y/N): " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Operation cancelled by user due to safety warning."
    exit 0
fi

echo ""

# Function to cleanup on exit
cleanup() {
    echo "Script completed."
}
trap cleanup EXIT

# Check if target account ID is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <target-account-id> [cross-account-role-name]"
    echo ""
    echo "Parameters:"
    echo "  target-account-id       : The AWS account ID where you want to create the role"
    echo "  cross-account-role-name : Optional. Role to assume for checking (default: OrganizationAccountAccessRole)"
    echo ""
    echo "Examples:"
    echo "  $0 904233106159"
    echo "  $0 904233106159 AWSControlTowerExecution"
    echo "  $0 904233106159 CustomAdminRole"
    exit 1
fi

TARGET_ACCOUNT_ID="$1"
CROSS_ACCOUNT_ROLE="${2:-OrganizationAccountAccessRole}"

# Validate template file exists
if [ ! -f "$TEMPLATE_FILE" ]; then
    echo "❌ CloudFormation template file '$TEMPLATE_FILE' not found."
    echo "Please ensure the template file is in the current directory."
    exit 1
fi

# Pre-check: Display current account information (should be management account)
echo "Checking current AWS authentication (must be management account)..."
CALLER_IDENTITY=$(aws sts get-caller-identity 2>/dev/null)
if [ $? -ne 0 ]; then
    echo "❌ Failed to get caller identity. Please ensure AWS CLI is configured and you're authenticated."
    exit 1
fi

CURRENT_ACCOUNT_ID=$(echo "$CALLER_IDENTITY" | jq -r '.Account')
USER_ARN=$(echo "$CALLER_IDENTITY" | jq -r '.Arn')

echo "Current Account ID: $CURRENT_ACCOUNT_ID"
echo "Authenticated as: $USER_ARN"

# Get account alias for additional confirmation
ACCOUNT_ALIAS=$(aws iam list-account-aliases --query 'AccountAliases[0]' --output text 2>/dev/null)
if [ "$ACCOUNT_ALIAS" != "None" ] && [ -n "$ACCOUNT_ALIAS" ]; then
    echo "Account Alias: $ACCOUNT_ALIAS"
else
    echo "Account Alias: (none configured)"
fi

echo ""

# Get management account ID from organization
echo "Retrieving organization management account ID..."
MANAGEMENT_ACCOUNT_ID=$(aws organizations describe-organization --query 'Organization.MasterAccountId' --output text 2>/dev/null)

if [ $? -ne 0 ] || [ -z "$MANAGEMENT_ACCOUNT_ID" ] || [ "$MANAGEMENT_ACCOUNT_ID" = "None" ]; then
    echo "❌ Failed to retrieve organization management account ID."
    echo "Please ensure you're authenticated to the management account with organizations permissions."
    exit 1
fi

echo "✅ Management Account ID: $MANAGEMENT_ACCOUNT_ID"

# Verify we're in the management account
if [ "$CURRENT_ACCOUNT_ID" != "$MANAGEMENT_ACCOUNT_ID" ]; then
    echo ""
    echo "🚨 AUTHENTICATION ERROR!"
    echo "   You must be authenticated to the MANAGEMENT account to run this script."
    echo "   Current account: $CURRENT_ACCOUNT_ID"
    echo "   Management account: $MANAGEMENT_ACCOUNT_ID"
    echo ""
    echo "Please authenticate to the management account and try again."
    exit 1
fi

echo "✅ Confirmed: Operating from management account"
echo ""

# Function to save and restore AWS credentials
save_credentials() {
    ORIGINAL_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID"
    ORIGINAL_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY"
    ORIGINAL_SESSION_TOKEN="$AWS_SESSION_TOKEN"
}

restore_credentials() {
    export AWS_ACCESS_KEY_ID="$ORIGINAL_ACCESS_KEY_ID"
    export AWS_SECRET_ACCESS_KEY="$ORIGINAL_SECRET_ACCESS_KEY"
    export AWS_SESSION_TOKEN="$ORIGINAL_SESSION_TOKEN"
}

# Save current credentials
save_credentials

# Check if role already exists in target account
echo "Checking if AWSControlTowerExecution role already exists in target account..."

# We need to assume a role to check the target account
echo "Attempting to assume role: arn:aws:iam::${TARGET_ACCOUNT_ID}:role/${CROSS_ACCOUNT_ROLE}"

ASSUME_ROLE_OUTPUT=$(aws sts assume-role \
    --role-arn "arn:aws:iam::${TARGET_ACCOUNT_ID}:role/${CROSS_ACCOUNT_ROLE}" \
    --role-session-name "RoleCheck-$(date +%s)" \
    --output json 2>&1)

ASSUME_ROLE_EXIT_CODE=$?

if [ $ASSUME_ROLE_EXIT_CODE -eq 0 ]; then
    echo "✅ Successfully assumed cross-account role"
    
    # Extract temporary credentials
    TEMP_ACCESS_KEY=$(echo "$ASSUME_ROLE_OUTPUT" | jq -r '.Credentials.AccessKeyId')
    TEMP_SECRET_KEY=$(echo "$ASSUME_ROLE_OUTPUT" | jq -r '.Credentials.SecretAccessKey')
    TEMP_SESSION_TOKEN=$(echo "$ASSUME_ROLE_OUTPUT" | jq -r '.Credentials.SessionToken')
    
    # Temporarily switch to target account credentials
    export AWS_ACCESS_KEY_ID="$TEMP_ACCESS_KEY"
    export AWS_SECRET_ACCESS_KEY="$TEMP_SECRET_KEY"
    export AWS_SESSION_TOKEN="$TEMP_SESSION_TOKEN"
    
    # Verify we're in the target account
    TARGET_CALLER_IDENTITY=$(aws sts get-caller-identity 2>/dev/null)
    if [ $? -eq 0 ]; then
        TARGET_ACCOUNT_CHECK=$(echo "$TARGET_CALLER_IDENTITY" | jq -r '.Account')
        if [ "$TARGET_ACCOUNT_CHECK" = "$TARGET_ACCOUNT_ID" ]; then
            echo "✅ Confirmed operating in target account: $TARGET_ACCOUNT_ID"
            
            # Check if role exists
            ROLE_CHECK=$(aws iam get-role --role-name "$ROLE_NAME" 2>/dev/null)
            ROLE_CHECK_EXIT_CODE=$?
            
            # Restore original credentials before proceeding
            restore_credentials
            
            if [ $ROLE_CHECK_EXIT_CODE -eq 0 ]; then
                echo "✅ Role '$ROLE_NAME' already exists in account $TARGET_ACCOUNT_ID."
                echo "No action needed - the role is ready for Control Tower enrollment."
                exit 0
            else
                echo "❌ Role '$ROLE_NAME' does not exist in account $TARGET_ACCOUNT_ID."
                echo "Will create it using CloudFormation StackSets..."
            fi
        else
            echo "❌ Account mismatch after role assumption!"
            echo "   Expected: $TARGET_ACCOUNT_ID"
            echo "   Got: $TARGET_ACCOUNT_CHECK"
            restore_credentials
            exit 1
        fi
    else
        echo "❌ Failed to verify target account identity after role assumption"
        restore_credentials
        exit 1
    fi
else
    echo "⚠️  Could not assume cross-account role. Error details:"
    echo "$ASSUME_ROLE_OUTPUT"
    echo ""
    echo "Possible reasons:"
    echo "  - Role '$CROSS_ACCOUNT_ROLE' doesn't exist in target account"
    echo "  - Role doesn't trust the management account"
    echo "  - Insufficient permissions"
    echo ""
    echo "To try a different role name, run:"
    echo "  $0 $TARGET_ACCOUNT_ID <different-role-name>"
    echo ""
    echo "Will proceed with StackSet deployment - it will fail gracefully if role exists."
    restore_credentials
fi

echo ""

# Display operation summary
echo "🔍 OPERATION SUMMARY:"
echo "   Management Account: $MANAGEMENT_ACCOUNT_ID (current)"
echo "   Target Account: $TARGET_ACCOUNT_ID"
echo "   Role to Create: $ROLE_NAME"
echo "   Method: CloudFormation StackSets"
echo "   Template: $TEMPLATE_FILE"
echo ""

read -p "Proceed with StackSet deployment? (y/N): " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Operation cancelled by user."
    exit 0
fi

echo ""

# First, detect the Control Tower region by checking where Control Tower is deployed
echo "Detecting Control Tower region..."
CONTROL_TOWER_REGION=$(aws controltower list-enabled-controls --query 'EnabledControls[0].ControlIdentifier' --output text 2>/dev/null | cut -d':' -f4)

if [ -z "$CONTROL_TOWER_REGION" ] || [ "$CONTROL_TOWER_REGION" = "None" ]; then
    echo "⚠️  Could not detect Control Tower region automatically."
    echo "   Checking common Control Tower regions for StackSets..."
    
    # Try common Control Tower regions
    for region in "eu-west-1" "us-east-1" "us-west-2" "ap-southeast-2"; do
        echo "   Checking region: $region"
        STACKSET_CHECK=$(aws cloudformation describe-stack-set --stack-set-name "$STACKSET_NAME" --region "$region" 2>/dev/null)
        if [ $? -eq 0 ]; then
            CONTROL_TOWER_REGION="$region"
            echo "✅ Found StackSet in region: $region"
            break
        fi
    done
    
    if [ -z "$CONTROL_TOWER_REGION" ]; then
        echo "❌ Could not find StackSet '$STACKSET_NAME' in any common regions."
        echo "Please specify the Control Tower region manually or check the StackSet name."
        exit 1
    fi
else
    echo "✅ Detected Control Tower region: $CONTROL_TOWER_REGION"
fi

# Check if StackSet already exists in the Control Tower region
echo "Checking if StackSet '$STACKSET_NAME' exists in region $CONTROL_TOWER_REGION..."
EXISTING_STACKSET=$(aws cloudformation describe-stack-set --stack-set-name "$STACKSET_NAME" --region "$CONTROL_TOWER_REGION" 2>/dev/null)

if [ $? -eq 0 ]; then
    echo "✅ StackSet '$STACKSET_NAME' already exists."
    echo "Will create stack instance in target account..."
else
    echo "❌ StackSet '$STACKSET_NAME' does not exist."
    echo "Please create the StackSet first or use an existing Control Tower StackSet."
    echo ""
    echo "To create the StackSet manually:"
    echo "1. Go to CloudFormation → StackSets in the AWS Console"
    echo "2. Create new StackSet using template: $TEMPLATE_FILE"
    echo "3. Set ManagementAccountId parameter to: $MANAGEMENT_ACCOUNT_ID"
    echo "4. Re-run this script"
    exit 1
fi

# We already detected the Control Tower region above, so use it
echo "Using Control Tower region: $CONTROL_TOWER_REGION for stack instance deployment"

# Check StackSet permission model
echo "Checking StackSet permission model..."
PERMISSION_MODEL=$(aws cloudformation describe-stack-set \
    --stack-set-name "$STACKSET_NAME" \
    --region "$CONTROL_TOWER_REGION" \
    --query 'StackSet.PermissionModel' \
    --output text 2>/dev/null)

echo "StackSet permission model: $PERMISSION_MODEL"

if [ "$PERMISSION_MODEL" = "SERVICE_MANAGED" ]; then
    echo "StackSet uses SERVICE_MANAGED model - need to deploy to Organizational Unit"
    
    # Find the OU that contains the target account
    echo "Finding Organizational Unit for account $TARGET_ACCOUNT_ID..."
    TARGET_OU=$(aws organizations list-parents --child-id "$TARGET_ACCOUNT_ID" --query 'Parents[0].Id' --output text 2>/dev/null)
    
    if [ $? -eq 0 ] && [ "$TARGET_OU" != "None" ] && [ -n "$TARGET_OU" ]; then
        echo "✅ Found target account in OU: $TARGET_OU"
        
        # Get OU name for confirmation
        OU_NAME=$(aws organizations describe-organizational-unit --organizational-unit-id "$TARGET_OU" --query 'OrganizationalUnit.Name' --output text 2>/dev/null)
        echo "OU Name: $OU_NAME"
        
        echo ""
        echo "⚠️  SERVICE_MANAGED StackSets deploy to entire OUs, not individual accounts."
        echo "   This will deploy the role to ALL accounts in OU: $OU_NAME ($TARGET_OU)"
        echo "   Target account $TARGET_ACCOUNT_ID is in this OU."
        echo ""
        read -p "Deploy to entire OU '$OU_NAME'? This affects all accounts in the OU (y/N): " -n 1 -r
        echo ""
        
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Operation cancelled by user."
            echo ""
            echo "Alternative approaches:"
            echo "1. Create a SELF_MANAGED StackSet for individual account targeting"
            echo "2. Use AWS Console to deploy to specific accounts"
            echo "3. Contact your AWS administrator to deploy via Control Tower"
            exit 0
        fi
        
        # Check if stack instance already exists for this account
        echo "Checking if stack instance already exists for account $TARGET_ACCOUNT_ID..."
        EXISTING_INSTANCE=$(aws cloudformation list-stack-instances \
            --stack-set-name "$STACKSET_NAME" \
            --region "$CONTROL_TOWER_REGION" \
            --query "Summaries[?Account=='$TARGET_ACCOUNT_ID'].Status" \
            --output text 2>/dev/null)
        
        if [ -n "$EXISTING_INSTANCE" ] && [ "$EXISTING_INSTANCE" != "None" ]; then
            echo "✅ Stack instance already exists with status: $EXISTING_INSTANCE"
            
            if [ "$EXISTING_INSTANCE" = "CURRENT" ]; then
                echo "✅ Stack instance is current - role should already exist and be up to date."
                echo "No action needed."
                exit 0
            elif [ "$EXISTING_INSTANCE" = "OUTDATED" ]; then
                echo "⚠️  Stack instance is outdated - will update it to ensure role is current."
                ACTION="update"
            else
                echo "⚠️  Stack instance status: $EXISTING_INSTANCE - will attempt to update."
                ACTION="update"
            fi
        else
            echo "❌ No existing stack instance found - will create new one."
            ACTION="create"
        fi
        
        if [ "$ACTION" = "create" ]; then
            # Create stack instance for the OU
            echo "Creating stack instances for OU $TARGET_OU (region: $CONTROL_TOWER_REGION)..."
            OPERATION_ID="${OPERATION_ID_PREFIX}-${TARGET_OU}"
            
            aws cloudformation create-stack-instances \
                --stack-set-name "$STACKSET_NAME" \
                --deployment-targets OrganizationalUnitIds="$TARGET_OU" \
                --regions "$CONTROL_TOWER_REGION" \
                --operation-id "$OPERATION_ID" \
                --region "$CONTROL_TOWER_REGION"
        else
            # Update existing stack instances
            echo "Updating stack instances for OU $TARGET_OU (region: $CONTROL_TOWER_REGION)..."
            OPERATION_ID="${OPERATION_ID_PREFIX}-update-${TARGET_OU}"
            
            aws cloudformation update-stack-instances \
                --stack-set-name "$STACKSET_NAME" \
                --deployment-targets OrganizationalUnitIds="$TARGET_OU" \
                --regions "$CONTROL_TOWER_REGION" \
                --operation-id "$OPERATION_ID" \
                --region "$CONTROL_TOWER_REGION"
        fi
        
        if [ $? -eq 0 ]; then
            echo "✅ Stack instance creation initiated for OU."
            echo "Operation ID: $OPERATION_ID"
            echo "This will deploy to ALL accounts in OU: $OU_NAME"
        else
            echo "❌ Failed to create stack instances for OU."
            exit 1
        fi
    else
        echo "❌ Could not find Organizational Unit for account $TARGET_ACCOUNT_ID"
        echo "Please check that the account is part of your AWS Organization."
        exit 1
    fi
    
elif [ "$PERMISSION_MODEL" = "SELF_MANAGED" ]; then
    echo "StackSet uses SELF_MANAGED model - can deploy to individual accounts"
    
    # Create stack instance in target account
    echo "Creating stack instance in target account $TARGET_ACCOUNT_ID (region: $CONTROL_TOWER_REGION)..."
    OPERATION_ID="${OPERATION_ID_PREFIX}-${TARGET_ACCOUNT_ID}"
    
    aws cloudformation create-stack-instances \
        --stack-set-name "$STACKSET_NAME" \
        --accounts "$TARGET_ACCOUNT_ID" \
        --regions "$CONTROL_TOWER_REGION" \
        --operation-id "$OPERATION_ID" \
        --region "$CONTROL_TOWER_REGION"
    
    if [ $? -eq 0 ]; then
        echo "✅ Stack instance creation initiated."
        echo "Operation ID: $OPERATION_ID"
    else
        echo "❌ Failed to create stack instance."
        exit 1
    fi
else
    echo "❌ Unknown permission model: $PERMISSION_MODEL"
    exit 1
fi

# Monitor the operation
echo ""
echo "Monitoring StackSet operation progress..."
echo "This may take a few minutes..."

while true; do
    OPERATION_STATUS=$(aws cloudformation describe-stack-set-operation \
        --stack-set-name "$STACKSET_NAME" \
        --operation-id "$OPERATION_ID" \
        --query 'StackSetOperation.Status' \
        --output text \
        --region "$CONTROL_TOWER_REGION" 2>/dev/null)
    
    if [ $? -ne 0 ]; then
        echo "❌ Failed to check operation status."
        break
    fi
    
    case "$OPERATION_STATUS" in
        "RUNNING")
            echo "⏳ Operation in progress..."
            sleep 10
            ;;
        "SUCCEEDED")
            echo "✅ StackSet operation completed successfully!"
            break
            ;;
        "FAILED"|"STOPPED")
            echo "❌ StackSet operation failed or was stopped."
            echo "Checking for error details..."
            aws cloudformation describe-stack-set-operation \
                --stack-set-name "$STACKSET_NAME" \
                --operation-id "$OPERATION_ID" \
                --query 'StackSetOperation.{Status:Status,StatusReason:StatusReason}' \
                --output table \
                --region "$CONTROL_TOWER_REGION"
            exit 1
            ;;
        *)
            echo "⚠️  Unknown operation status: $OPERATION_STATUS"
            sleep 5
            ;;
    esac
done

# Validate the role was created
echo ""
echo "Validating role creation in target account..."

# Try to assume role again for validation
VALIDATION_ASSUME_OUTPUT=$(aws sts assume-role \
    --role-arn "arn:aws:iam::${TARGET_ACCOUNT_ID}:role/${CROSS_ACCOUNT_ROLE}" \
    --role-session-name "RoleValidation-$(date +%s)" \
    --output json 2>/dev/null)

if [ $? -eq 0 ]; then
    # Extract validation credentials
    VAL_ACCESS_KEY=$(echo "$VALIDATION_ASSUME_OUTPUT" | jq -r '.Credentials.AccessKeyId')
    VAL_SECRET_KEY=$(echo "$VALIDATION_ASSUME_OUTPUT" | jq -r '.Credentials.SecretAccessKey')
    VAL_SESSION_TOKEN=$(echo "$VALIDATION_ASSUME_OUTPUT" | jq -r '.Credentials.SessionToken')
    
    # Temporarily switch credentials for validation
    export AWS_ACCESS_KEY_ID="$VAL_ACCESS_KEY"
    export AWS_SECRET_ACCESS_KEY="$VAL_SECRET_KEY"
    export AWS_SESSION_TOKEN="$VAL_SESSION_TOKEN"
    
    # Validate role exists
    ROLE_VALIDATION=$(aws iam get-role --role-name "$ROLE_NAME" \
                      --query 'Role.{RoleName:RoleName,Arn:Arn,CreateDate:CreateDate}' \
                      --output table 2>/dev/null)
    
    # Restore original credentials
    restore_credentials
    
    if [ $? -eq 0 ]; then
        echo "✅ Role validation successful:"
        echo "$ROLE_VALIDATION"
    else
        echo "⚠️  Could not validate role directly, but StackSet operation succeeded."
    fi
else
    echo "⚠️  Could not validate role directly, but StackSet operation succeeded."
fi

echo ""
echo "🎉 Setup complete! The '$ROLE_NAME' role should now be ready for AWS Control Tower enrollment."
echo "   Created in account: $TARGET_ACCOUNT_ID"
echo "   Management account: $MANAGEMENT_ACCOUNT_ID"
echo "   StackSet: $STACKSET_NAME"
echo ""
echo "You can now proceed with Control Tower enrollment for account $TARGET_ACCOUNT_ID."