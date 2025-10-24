# TheToolShed

> "If it saves time twice, it belongs in here."

A personal collection of deployment scripts, infrastructure templates, and automation examples built for AWS environments. This repository serves as a practical DevOps workbench that captures repeatable solutions, time-saving utilities, and deployment patterns.

## Repository Structure

```
TheToolShed/
├── aws/                  # AWS-specific tools and templates
│   ├── cli/              # AWS CLI scripts and helper commands
│   ├── terraform/        # Terraform modules, templates, and examples
│   ├── terragrunt/       # Terragrunt configurations and patterns
│   └── utilities/        # Validation, linting, and automation scripts
├── shared/               # Cross-tool templates, pipelines, and scripts
├── experiments/          # Proof-of-concepts, tests, and quick builds
└── archive/              # Retired or reference material
```

## Subfolder Organization

Each vendor directory follows a consistent structure for easy navigation:

| Subfolder | Purpose | Example Content |
|-----------|---------|-----------------|
| `examples/` | Working mini-projects | Complete deployments, usage demos |
| `templates/` | Clean starting points | Parameterized configs, boilerplate code |
| `modules/` | Reusable components | Terraform modules, shared libraries |
| `scripts/` | Automation tools | Deployment scripts, helper utilities |
| `validation/` | Quality assurance | Linting, policy checks, testing tools |

## Quick Start

1. Browse the relevant vendor directory (`aws/`)
2. Check the specific tool directory (`cli/`, `terraform/`, etc.)
3. Look in `examples/` for working implementations
4. Use `templates/` as starting points for new projects
5. Leverage `scripts/` for automation needs

## Target Audience

- AWS Solutions Architects
- DevOps Engineers
- Infrastructure Engineers  
- Cloud Engineers working with AWS

Content assumes familiarity with AWS services, Terraform, and basic shell scripting.

## Contributing

Follow the established patterns and structure when adding new content. Each directory should include appropriate documentation and follow AWS best practices.