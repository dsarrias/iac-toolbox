FROM alpine:3.20

# Install dependencies
RUN apk add --no-cache \
    bash \
    curl \
    wget \
    git \
    unzip \
    jq \
    yq \
    openssl \
    ansible \
    ca-certificates \
    && update-ca-certificates

# Versions
ARG TERRAFORM_VERSION=1.12.2
ARG TERRAGRUNT_VERSION=0.83.2
ARG TOFU_VERSION=1.10.3
ARG TRIVY_VERSION=0.64.1
ARG TFSEC_VERSION=1.28.14
ARG TFLINT_VERSION=0.58.1
ARG TERRAFORM_DOCS_VERSION=0.20.0

# Install Terraform
RUN wget -q https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    && unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    && mv terraform /usr/local/bin/ \
    && rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip

# Install Terragrunt
RUN wget -q https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/terragrunt_linux_amd64 \
    && chmod +x terragrunt_linux_amd64 \
    && mv terragrunt_linux_amd64 /usr/local/bin/terragrunt

# Install OpenTofu
RUN wget -q https://github.com/opentofu/opentofu/releases/download/v${TOFU_VERSION}/tofu_${TOFU_VERSION}_linux_amd64.zip \
    && unzip tofu_${TOFU_VERSION}_linux_amd64.zip \
    && mv tofu /usr/local/bin/ \
    && rm tofu_${TOFU_VERSION}_linux_amd64.zip

# Install Trivy
RUN wget -q https://github.com/aquasecurity/trivy/releases/download/v${TRIVY_VERSION}/trivy_${TRIVY_VERSION}_Linux-64bit.tar.gz \
    && tar -xzf trivy_${TRIVY_VERSION}_Linux-64bit.tar.gz \
    && mv trivy /usr/local/bin/ \
    && rm trivy_${TRIVY_VERSION}_Linux-64bit.tar.gz

# Install tfsec
RUN wget -q https://github.com/aquasecurity/tfsec/releases/download/v${TFSEC_VERSION}/tfsec-linux-amd64 \
    && chmod +x tfsec-linux-amd64 \
    && mv tfsec-linux-amd64 /usr/local/bin/tfsec

# Install tflint
RUN wget -q https://github.com/terraform-linters/tflint/releases/download/v${TFLINT_VERSION}/tflint_linux_amd64.zip \
    && unzip tflint_linux_amd64.zip \
    && mv tflint /usr/local/bin/ \
    && rm tflint_linux_amd64.zip

# Install terraform-docs
RUN wget -q https://github.com/terraform-docs/terraform-docs/releases/download/v${TERRAFORM_DOCS_VERSION}/terraform-docs-v${TERRAFORM_DOCS_VERSION}-linux-amd64.tar.gz \
    && tar -xzf terraform-docs-v${TERRAFORM_DOCS_VERSION}-linux-amd64.tar.gz \
    && mv terraform-docs /usr/local/bin/ \
    && rm terraform-docs-v${TERRAFORM_DOCS_VERSION}-linux-amd64.tar.gz

# Set default shell
CMD ["/bin/bash"]
