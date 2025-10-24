# TheToolShed Project Standards

## Project Philosophy
> "If it saves time twice, it belongs in here."

TheToolShed is a personal collection of deployment scripts, infrastructure templates, and automation examples built for AWS environments. It serves as a practical DevOps workbench that captures repeatable solutions, time-saving utilities, and deployment patterns.

## Repository Structure Standards

Follow this established structure when adding new content:

```
TheToolShed/
├── aws/
│   ├── cli/              # AWS CLI scripts and helper commands
│   ├── terraform/        # Terraform modules, templates, and examples
│   ├── terragrunt/       # Terragrunt configurations and patterns
│   └── utilities/        # Validation, linting, and automation scripts
├── shared/               # Cross-tool templates, pipelines, and scripts
├── experiments/          # Proof-of-concepts, tests, and quick builds
└── archive/              # Retired or reference material
```

## Naming Conventions

- **Directories**: Lowercase and hyphenated (`terraform-vpc-example`)
- **Scripts**: Simple, self-documenting names (`assume-role.sh`, `cleanup-old-resources.sh`)
- **Files**: Clear purpose indication in naming

## Documentation Requirements

- **README.md** required in every main directory
- Include context and usage examples
- Provide working references in `examples/` directories
- Create clean starting points in templates

## Content Categories

### Examples
- Show working usage with real-world scenarios
- Include minimal setup requirements
- Provide copy-paste ready configurations

### Templates  
- Clean starting points for new deployments
- Well-commented and parameterized
- Follow AWS best practices

### Scripts
- Focus on AWS CLI, Terraform, and Terragrunt
- Include error handling and validation
- Self-documenting with clear variable names

## AWS-Specific Guidelines

- Use AWS CLI v2 syntax and features
- Follow AWS Well-Architected Framework principles
- Implement proper IAM least-privilege access
- Include resource tagging strategies
- Consider multi-account deployment patterns

## Code Quality Standards

- Scripts should be idempotent where possible
- Include proper error handling and logging
- Use consistent formatting and style
- Add inline comments for complex logic
- Validate inputs and prerequisites

## Security Considerations

- Never commit sensitive data (credentials, keys, etc.)
- Use parameter stores or environment variables for secrets
- Implement proper IAM role assumptions
- Follow AWS security best practices
- Include security validation in utilities

## Evolution Guidelines

- Tools may start experimental in `experiments/`
- Move to appropriate category when proven useful
- Archive deprecated but potentially useful content
- Maintain backward compatibility when possible
- Document breaking changes clearly

## Target Audience

Content should be suitable for:
- AWS Solutions Architects
- DevOps Engineers  
- Infrastructure Engineers
- Cloud Engineers working with AWS

Assume familiarity with AWS services, Terraform, and basic shell scripting.