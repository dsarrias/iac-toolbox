# IaC Toolbox Docker Image

A lightweight, Alpine-based Docker image that bundles essential Infrastructure-as-Code (IaC) tools into a single, ready-to-use container. Designed to simplify your cloud infrastructure workflows by providing:

- **Terraform** — Infrastructure provisioning  
- **Terragrunt** — Terraform wrapper for DRY configurations  
- **OpenTofu** — Terraform-compatible open source infrastructure tool  
- **Trivy** — Security scanner for container images and IaC  
- **tfsec** — Static analysis security scanner for Terraform  
- **tflint** — Terraform linter for best practices  
- **terraform-docs** — Automatically generate documentation from Terraform modules  

---

## Why use this image?

- **Simplified toolchain** — no need to install or manage tools locally  
- **Lightweight** — based on Alpine Linux  
- **Consistent environment** — ideal for CI/CD pipelines and local development  
- **Easy integration** — ready to use with Docker Compose or as a standalone container  

---

## Usage example (Docker Compose)

```yaml
services:
  iac-cli:
    image: yourusername/iac-toolbox:local
    user: "${MYUID}:${MYGID}"
    volumes:
      - .:/app
    working_dir: /app
    entrypoint: ["/bin/bash"]
    tty: true
