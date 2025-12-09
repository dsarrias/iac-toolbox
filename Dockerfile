FROM alpine:3.23

# Dependency and tool versions
ARG BASH_VERSION=5.3.3
ARG WGET_VERSION=1.25.0
ARG UNZIP_VERSION=6.0
ARG TAR_VERSION=1.35
ARG GIT_VERSION=2.52.0
ARG CA_CERTS_VERSION=20251003
ARG CURL_VERSION=8.17.0
ARG GREP_VERSION=3.12
ARG PYTHON3_VERSION=3.12.12
ARG JQ_VERSION=1.8.1
ARG ZIP_VERSION=3.0
ARG MYSQL_CLIENT_VERSION=11.4.9
ARG OPENSSH_VERSION=10.2
ARG AWS_CLI_VERSION=2.32.7

ARG TERRAFORM_VERSION=1.14.1
ARG TERRAGRUNT_VERSION=0.93.13
ARG TOFU_VERSION=1.10.7
ARG TRIVY_VERSION=0.68.1
ARG TFLINT_VERSION=0.60.0
ARG TERRAFORM_DOCS_VERSION=0.20.0

# Install dependencies and tools
RUN set -eu && apk update && apk add --no-cache \
    bash~=${BASH_VERSION} \
    wget~=${WGET_VERSION} \
    unzip~=${UNZIP_VERSION} \
    tar~=${TAR_VERSION} \
    git~=${GIT_VERSION} \
    curl~=${CURL_VERSION} \
    grep~=${GREP_VERSION} \
    python3~=${PYTHON3_VERSION} \
    jq~=${JQ_VERSION} \
    zip~=${ZIP_VERSION} \
    mariadb-client~=${MYSQL_CLIENT_VERSION} \
    openssh~=${OPENSSH_VERSION} \
    aws-cli~=${AWS_CLI_VERSION} \
    ca-certificates~=${CA_CERTS_VERSION} && \
    update-ca-certificates && \
    addgroup -S appgroup && adduser -S appuser -G appgroup

# Install Terraform
RUN wget -q https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    mv terraform /usr/local/bin/ && \
    rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip LICENSE.txt

# Install Terragrunt
RUN wget -q https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/terragrunt_linux_amd64 && \
    chmod +x terragrunt_linux_amd64 && \
    mv terragrunt_linux_amd64 /usr/local/bin/terragrunt

# Install OpenTofu
RUN wget -q https://github.com/opentofu/opentofu/releases/download/v${TOFU_VERSION}/tofu_${TOFU_VERSION}_linux_amd64.zip && \
    unzip tofu_${TOFU_VERSION}_linux_amd64.zip && \
    mv tofu /usr/local/bin/ && \
    rm tofu_${TOFU_VERSION}_linux_amd64.zip CHANGELOG.md

# Install Trivy
RUN wget -q https://github.com/aquasecurity/trivy/releases/download/v${TRIVY_VERSION}/trivy_${TRIVY_VERSION}_Linux-64bit.tar.gz && \
    tar -xzf trivy_${TRIVY_VERSION}_Linux-64bit.tar.gz && \
    mv trivy /usr/local/bin/ && \
    rm trivy_${TRIVY_VERSION}_Linux-64bit.tar.gz

# Install tflint
RUN wget -q https://github.com/terraform-linters/tflint/releases/download/v${TFLINT_VERSION}/tflint_linux_amd64.zip && \
    unzip tflint_linux_amd64.zip && \
    mv tflint /usr/local/bin/ && \
    rm tflint_linux_amd64.zip

# Install terraform-docs
RUN wget -q https://github.com/terraform-docs/terraform-docs/releases/download/v${TERRAFORM_DOCS_VERSION}/terraform-docs-v${TERRAFORM_DOCS_VERSION}-linux-amd64.tar.gz && \
    tar -xzf terraform-docs-v${TERRAFORM_DOCS_VERSION}-linux-amd64.tar.gz && \
    mv terraform-docs /usr/local/bin/ && \
    rm terraform-docs-v${TERRAFORM_DOCS_VERSION}-linux-amd64.tar.gz README.md LICENSE

HEALTHCHECK --interval=5m --timeout=3s \
  CMD terraform --version || exit 1

USER appuser

# Set default shell
CMD ["/bin/bash"]