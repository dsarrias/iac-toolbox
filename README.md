# IaC Toolbox Docker Image

An **Alpine-based, all-in-one Docker image** that bundles essential Infrastructure-as-Code (IaC) and automation tools into a single, ready-to-use container. Now optimized for **Multi-Architecture** support (AMD64 & ARM64).

Designed to simplify cloud infrastructure workflows by providing:

- **Terraform** — Infrastructure provisioning
- **Terragrunt** — Terraform wrapper for DRY configurations
- **OpenTofu** — Terraform-compatible open source infrastructure tool
- **Trivy** — Security scanner for container images and IaC
- **tflint** — Terraform linter for best practices
- **terraform-docs** — Automatically generate documentation from Terraform modules
- **General tools** such as bash, wget, git, etc.

---

## Why use this image?

- **Multi-Arch Support** — runs natively on both Intel/AMD (x86_64) and Apple Silicon/ARM (aarch64)
- **Unified toolchain** — no need to install or manage tools locally  
- **Compact and efficient** — based on Alpine Linux, optimized for CI/CD  
- **Consistent environment** — eliminate “works on my machine” issues  
- **Seamless integration** — ready for Docker Compose, pipelines, or local use

---

## Usage example (Docker Compose)

The image automatically detects your system architecture (amd64/arm64) and pulls the correct version.

```yaml
services:
  iac-cli:
    image: dsarrias/iac-toolbox:latest
    user: "${MYUID}:${MYGID}"
    volumes:
      - .:/app
    working_dir: /app
    tty: true