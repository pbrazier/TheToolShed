# AWS Control Tower Execution Role Deployment

This directory contains scripts and templates for deploying the AWS Control Tower execution role to AWS accounts.

## Files

- `deploy-control-tower-role-stackset.sh` - Deployment script for creating the Control Tower execution role
- `control-tower-role-template.yaml` - CloudFormation template defining the IAM role and permissions

## Overview

The AWS Control Tower execution role is required for Control Tower to manage resources in member accounts. This role provides the necessary permissions for Control Tower to:

- Deploy and manage guardrails
- Set up logging and monitoring
- Configure organizational units (OUs)
- Manage account lifecycle operations

## Prerequisites

- AWS CLI v2 installed and configured
- Appropriate IAM permissions to create roles and deploy CloudFormation stacks
- Access to the AWS Organizations management account (if deploying via StackSets)

## Usage

### Basic Deployment

```bash
./deploy-control-tower-role-stackset.sh
```

### Script Dependencies

The deployment script typically requires:
- The CloudFormation template (`control-tower-role-template.yaml`)
- Valid AWS credentials with sufficient permissions
- Target account IDs or organizational unit specifications

## Template Contents

The CloudFormation template defines:
- IAM role with Control Tower trust policy
- Required permissions for Control Tower operations
- Cross-account access policies
- Logging and monitoring configurations

## Security Considerations

- The execution role grants significant permissions to Control Tower
- Review the template permissions before deployment
- Ensure proper trust relationships are configured
- Monitor role usage through CloudTrail

## Troubleshooting

Common issues:
- Insufficient permissions for role creation
- Trust policy misconfigurations
- StackSet deployment failures in target accounts
- Existing role conflicts

## Notes

- This role is typically deployed once per account during Control Tower setup
- Updates to the role may require redeployment across all managed accounts
- Consider using StackSets for multi-account deployments