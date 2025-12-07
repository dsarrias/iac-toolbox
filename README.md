# IaC Toolbox Docker Image

An **Alpine-based, all-in-one Docker image** that bundles essential Infrastructure-as-Code (IaC) and automation tools into a single, ready-to-use container.  
Designed to simplify cloud infrastructure workflows by providing:

- **Terraform** — Infrastructure provisioning
- **Terragrunt** — Terraform wrapper for DRY configurations
- **OpenTofu** — Terraform-compatible open source infrastructure tool
- **Trivy** — Security scanner for container images and IaC
- **tflint** — Terraform linter for best practices
- **terraform-docs** — Automatically generate documentation from Terraform modules
- **General tools** such as bash, wget, git etc

---

## Why use this image?

- **Unified toolchain** — no need to install or manage tools locally  
- **Compact and efficient** — based on Alpine Linux, optimized for CI/CD  
- **Consistent environment** — eliminate “works on my machine” issues  
- **Seamless integration** — ready for Docker Compose, pipelines, or local use

---

## Usage example (Docker Compose)

```yaml
services:
  iac-cli:
    image: dsarrias/iac-toolbox:latest
    user: "${MYUID}:${MYGID}"
    volumes:
      - .:/app
    working_dir: /app
    tty: true
```

## Notes
- By default Terragrunt uses OpenTofu. You can set Terraform by simply adding the following environment variable to the compose file
`TG_TF_PATH=/usr/local/bin/terraform`
