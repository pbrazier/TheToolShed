# TheToolShed 🧰

A personal collection of deployment scripts, infrastructure templates, and automation examples built for AWS environments using **AWS CLI**, **Terraform**, and **Terragrunt**.

*TheToolShed* is where useful tools, snippets, and experiments live before they become production-ready. Think of it as a practical DevOps workbench: organised enough to find what you need, but still with that “shed” charm.

---

## 🗂 Repository Structure

```plaintext
TheToolShed/
├── aws/
│   ├── cli/              # AWS CLI scripts and helper commands
│   ├── terraform/        # Terraform modules, templates, and examples
│   ├── terragrunt/       # Terragrunt configurations and patterns
│   └── utilities/        # Validation, linting, and automation scripts
│
├── shared/               # Cross-tool templates, pipelines, and scripts
├── experiments/           # Proof-of-concepts, tests, and quick builds
└── archive/               # Retired or reference material
```

*Each directory includes its own README for context and usage examples.*

---

## ⚙️ Usage

Clone the repository and explore any folder:

```bash
git clone https://github.com/<your-username>/TheToolShed.git
cd TheToolShed
```

Each sub-folder includes examples or templates with minimal setup requirements.  
Use the `examples/` directories as working references, or copy templates to kick-start new deployments.

---

## 🧩 Folder Overview

| Folder | Purpose | Example contents |
|---------|----------|------------------|
| `aws/cli/` | AWS CLI scripts and automation helpers | IAM audits, Control Tower enrolment, S3 lifecycle cleanup |
| `aws/terraform/` | Terraform templates and reusable IaC modules | VPC, RDS, S3, and IAM configurations |
| `aws/terragrunt/` | Terragrunt patterns for DRY deployments | Environment HCLs and multi-account orchestration |
| `aws/utilities/` | Shell or Python utilities for validation and automation | Linting, tag validation, security checks |
| `shared/` | Common resources used across clouds and tools | CI/CD templates, tagging policies, cross-account scripts |
| `experiments/` | A space for testing and tinkering | EventBridge to Slack, LocalStack, AI tool integrations |
| `archive/` | Old but occasionally useful content | Deprecated Terraform examples and scripts |

---

## 🧱 Naming and Standards

- **Lowercase and hyphenated** directories (`terraform-vpc-example`)  
- **README.md** in every main directory for clarity  
- **Examples** show working usage  
- **Templates** provide clean starting points  
- **Scripts** use simple, self-documenting names (`assume-role.sh`, `cleanup-old-resources.sh`)  

---

## 🧠 Philosophy

> “If it saves time twice, it belongs in here.”

This repository captures repeatable solutions, time-saving utilities, and deployment patterns that make cloud projects smoother. It’s equal parts toolkit, scratchpad, and archive.

---

## 🚀 Future Additions

- CI/CD pipeline templates for multi-account deployments  
- Modular AWS Control Tower enrolment scripts  
- Common validation workflows for Terraform and Terragrunt  
- Cost analysis and tagging automation tools  

---

## 🪴 Notes

*TheToolShed* evolves as new challenges appear. Some tools may be experimental; others are hardened and ready to reuse.  
Use, adapt, or extend anything here that helps you build faster and cleaner infrastructure.

---

*Created and maintained by Paul Brazier — AWS Solutions Architect, tinkerer, and occasional Terraform whisperer.*
