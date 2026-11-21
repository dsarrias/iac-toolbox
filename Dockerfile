FROM alpine:3.24 AS base

ARG TARGETARCH

# Dependency and tool versions
ARG BASH_VERSION=5.3
ARG WGET_VERSION=1.25
ARG UNZIP_VERSION=6.0
ARG TAR_VERSION=1.35
ARG GIT_VERSION=2.54
ARG CURL_VERSION=8.23
ARG GREP_VERSION=3.12
ARG PYTHON3_VERSION=3.14
ARG JQ_VERSION=1.8
ARG ZIP_VERSION=3.0
ARG MYSQL_CLIENT_VERSION=11.8
ARG OPENSSH_VERSION=10.3
ARG AWS_CLI_VERSION=2.34

ARG TERRAFORM_VERSION=1.17.2
ARG TERRAGRUNT_VERSION=1.2.2
ARG TOFU_VERSION=1.13.9
ARG TRIVY_VERSION=0.76.2
ARG TFLINT_VERSION=0.66.0
ARG TERRAFORM_DOCS_VERSION=0.25.1

# Install dependencies and tools
RUN set -eu && apk update && apk upgrade --no-cache && apk add --no-cache \
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
    ca-certificates && \
    update-ca-certificates && \
    addgroup -S appgroup && adduser -S appuser -G appgroup

# Install Terraform
RUN wget -q https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_${TARGETARCH}.zip && \
    unzip terraform_${TERRAFORM_VERSION}_linux_${TARGETARCH}.zip && \
    mv terraform /usr/local/bin/ && \
    rm terraform_${TERRAFORM_VERSION}_linux_${TARGETARCH}.zip LICENSE.txt

# Install Terragrunt
RUN wget -q https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/terragrunt_linux_${TARGETARCH} && \
    chmod +x terragrunt_linux_${TARGETARCH} && \
    mv terragrunt_linux_${TARGETARCH} /usr/local/bin/terragrunt

# Install OpenTofu
RUN wget -q https://github.com/opentofu/opentofu/releases/download/v${TOFU_VERSION}/tofu_${TOFU_VERSION}_linux_${TARGETARCH}.zip && \
    unzip tofu_${TOFU_VERSION}_linux_${TARGETARCH}.zip && \
    mv tofu /usr/local/bin/ && \
    rm tofu_${TOFU_VERSION}_linux_${TARGETARCH}.zip CHANGELOG.md

# Install Trivy
RUN case "${TARGETARCH}" in \
        "amd64") TRIVY_ARCH="64bit" ;; \
        "arm64") TRIVY_ARCH="ARM64" ;; \
        *) echo "Unsupported architecture: ${TARGETARCH}"; exit 1 ;; \
    esac && \
    wget -q https://github.com/aquasecurity/trivy/releases/download/v${TRIVY_VERSION}/trivy_${TRIVY_VERSION}_Linux-${TRIVY_ARCH}.tar.gz && \
    tar -xzf trivy_${TRIVY_VERSION}_Linux-${TRIVY_ARCH}.tar.gz && \
    mv trivy /usr/local/bin/ && \
    rm trivy_${TRIVY_VERSION}_Linux-${TRIVY_ARCH}.tar.gz

# Install tflint
RUN wget -q https://github.com/terraform-linters/tflint/releases/download/v${TFLINT_VERSION}/tflint_linux_${TARGETARCH}.zip && \
    unzip tflint_linux_${TARGETARCH}.zip && \
    mv tflint /usr/local/bin/ && \
    rm tflint_linux_${TARGETARCH}.zip

# Install terraform-docs
RUN wget -q https://github.com/terraform-docs/terraform-docs/releases/download/v${TERRAFORM_DOCS_VERSION}/terraform-docs-v${TERRAFORM_DOCS_VERSION}-linux-${TARGETARCH}.tar.gz && \
    tar -xzf terraform-docs-v${TERRAFORM_DOCS_VERSION}-linux-${TARGETARCH}.tar.gz && \
    mv terraform-docs /usr/local/bin/ && \
    rm terraform-docs-v${TERRAFORM_DOCS_VERSION}-linux-${TARGETARCH}.tar.gz README.md LICENSE

HEALTHCHECK --interval=5m --timeout=3s \
  CMD terraform --version || exit 1

USER appuser

# Set default shell
CMD ["/bin/bash"]

# Kubernetes variant (build with --target k8s)
FROM base AS k8s

ARG TARGETARCH

ARG KUBECTL_VERSION=1.37.2
ARG HELM_VERSION=4.3.2
ARG K9S_VERSION=0.51.0

USER root

# Install kubectl
RUN wget -q https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/${TARGETARCH}/kubectl && \
    chmod +x kubectl && \
    mv kubectl /usr/local/bin/

# Install Helm
RUN wget -q https://get.helm.sh/helm-v${HELM_VERSION}-linux-${TARGETARCH}.tar.gz && \
    tar -xzf helm-v${HELM_VERSION}-linux-${TARGETARCH}.tar.gz && \
    mv linux-${TARGETARCH}/helm /usr/local/bin/ && \
    rm -r helm-v${HELM_VERSION}-linux-${TARGETARCH}.tar.gz linux-${TARGETARCH}

# Install k9s
RUN wget -q https://github.com/derailed/k9s/releases/download/v${K9S_VERSION}/k9s_Linux_${TARGETARCH}.tar.gz && \
    tar -xzf k9s_Linux_${TARGETARCH}.tar.gz && \
    mv k9s /usr/local/bin/ && \
    rm k9s_Linux_${TARGETARCH}.tar.gz README.md LICENSE

USER appuser

# Standard image (default target)
FROM base AS standard