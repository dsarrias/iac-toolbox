# Variables
IMAGE_NAME ?= iac-toolbox
TAG ?= local

# Settings
.SILENT:
.DEFAULT_GOAL := help

# Targets
.PHONY: test
test: lint build dockle trivy clean ## Run full pipeline (Lint -> Build -> Audit -> Scan -> Clean)

.PHONY: lint
lint: ## Check Dockerfile syntax (Hadolint)
	@echo "--- 🔍 Running Hadolint ---"
	docker run --rm -i hadolint/hadolint < Dockerfile

.PHONY: build
build: ## Build Docker AMD image
	@echo "--- 🏗️ Building AMD Image ---"
	docker build --no-cache --platform linux/amd64 -t $(IMAGE_NAME):$(TAG) .

.PHONY: buildx
buildx: ## Build Docker ARM image 
	@echo "--- 🏗️ Building ARM Image ---"
	docker buildx build --no-cache --platform linux/arm64 -t $(IMAGE_NAME):$(TAG) --load .
	
.PHONY: dockle
dockle: ## Audit image best practices (Dockle)
	@echo "--- 🛡️ Running Dockle ---"
	docker run --rm \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v "$(shell pwd)/.dockleignore:/.dockleignore" \
		goodwithtech/dockle:latest --exit-code 1 $(IMAGE_NAME):$(TAG)

.PHONY: trivy
trivy: ## Scan for vulnerabilities (Trivy)
	@echo "--- 🦠 Running Trivy ---"
	docker run --rm \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v "$(shell pwd)/.trivyignore:/.trivyignore" \
		aquasec/trivy:latest image \
		--severity UNKNOWN,LOW,MEDIUM,HIGH,CRITICAL --exit-code 1 --ignore-unfixed --no-progress \
		--skip-files "/usr/local/bin/terraform,/usr/local/bin/terragrunt,/usr/local/bin/tofu,/usr/local/bin/tflint,/usr/local/bin/terraform-docs,/usr/local/bin/trivy" \
		$(IMAGE_NAME):$(TAG)

.PHONY: run
run: ## Run image interactively
	docker run --rm -it $(IMAGE_NAME):$(TAG) bash

.PHONY: debug
debug: build run ## Build and immediately enter container

.PHONY: clean
clean: ## Remove local Docker image
	docker rmi $(IMAGE_NAME):$(TAG) || true

# ------------------------------------------------------------------------------
# Wolfi Flavor
# ------------------------------------------------------------------------------

.PHONY: test-wolfi
test-wolfi: lint-wolfi build-wolfi dockle-wolfi trivy-wolfi clean-wolfi ## Run full pipeline (Lint -> Build -> Audit -> Scan -> Clean)

.PHONY: lint-wolfi
lint-wolfi: ## Check Dockerfile syntax (Hadolint)
	@echo "--- 🔍 Running Hadolint (Wolfi) ---"
	docker run --rm -i hadolint/hadolint hadolint --ignore DL3007 --ignore DL3018 - < Dockerfile.wolfi

.PHONY: build-wolfi
build-wolfi: ## Build Wolfi AMD image
	@echo "--- 🏗️ Building Wolfi AMD Image ---"
	docker build --no-cache --platform linux/amd64 -f Dockerfile.wolfi -t $(IMAGE_NAME):wolfi-$(TAG) .

.PHONY: buildx-wolfi
buildx-wolfi: ## Build Wolfi ARM image
	@echo "--- 🏗️ Building Wolfi ARM Image ---"
	docker buildx build --no-cache --platform linux/arm64 -f Dockerfile.wolfi -t $(IMAGE_NAME):wolfi-$(TAG) --load .

.PHONY: dockle-wolfi
dockle-wolfi: ## Audit Wolfi image best practices
	@echo "--- 🛡️ Running Dockle (Wolfi) ---"
	docker run --rm \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v "$(shell pwd)/.dockleignore:/.dockleignore" \
		goodwithtech/dockle:latest --exit-code 1 $(IMAGE_NAME):wolfi-$(TAG)

.PHONY: trivy-wolfi
trivy-wolfi: ## Scan Wolfi image for vulnerabilities
	@echo "--- 🦠 Running Trivy (Wolfi) ---"
	docker run --rm \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v "$(shell pwd)/.trivyignore:/.trivyignore" \
		aquasec/trivy:latest image \
		--severity UNKNOWN,LOW,MEDIUM,HIGH,CRITICAL --exit-code 1 --ignore-unfixed --no-progress \
		--skip-files "/usr/local/bin/terraform,/usr/local/bin/terragrunt,/usr/local/bin/tofu,/usr/local/bin/tflint,/usr/local/bin/terraform-docs,/usr/local/bin/trivy" \
		$(IMAGE_NAME):wolfi-$(TAG)

.PHONY: run-wolfi
run-wolfi: ## Run Wolfi image interactively
	docker run --rm -it $(IMAGE_NAME):wolfi-$(TAG) bash

.PHONY: debug-wolfi
debug-wolfi: build-wolfi run-wolfi ## Build and run Wolfi image

.PHONY: clean-wolfi
clean-wolfi: ## Remove local Wolfi Docker image
	docker rmi $(IMAGE_NAME):wolfi-$(TAG) || true

# ------------------------------------------------------------------------------
# Kubernetes Variant
# ------------------------------------------------------------------------------

.PHONY: test-k8s
test-k8s: lint build-k8s dockle-k8s trivy-k8s clean-k8s ## Run full pipeline for the k8s variant

.PHONY: build-k8s
build-k8s: ## Build k8s AMD image
	@echo "--- 🏗️ Building k8s AMD Image ---"
	docker build --no-cache --platform linux/amd64 --target k8s -t $(IMAGE_NAME):k8s-$(TAG) .

.PHONY: buildx-k8s
buildx-k8s: ## Build k8s ARM image
	@echo "--- 🏗️ Building k8s ARM Image ---"
	docker buildx build --no-cache --platform linux/arm64 --target k8s -t $(IMAGE_NAME):k8s-$(TAG) --load .

.PHONY: dockle-k8s
dockle-k8s: ## Audit k8s image best practices
	@echo "--- 🛡️ Running Dockle (k8s) ---"
	docker run --rm \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v "$(shell pwd)/.dockleignore:/.dockleignore" \
		goodwithtech/dockle:latest --exit-code 1 $(IMAGE_NAME):k8s-$(TAG)

.PHONY: trivy-k8s
trivy-k8s: ## Scan k8s image for vulnerabilities
	@echo "--- 🦠 Running Trivy (k8s) ---"
	docker run --rm \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v "$(shell pwd)/.trivyignore:/.trivyignore" \
		aquasec/trivy:latest image \
		--severity UNKNOWN,LOW,MEDIUM,HIGH,CRITICAL --exit-code 1 --ignore-unfixed --no-progress \
		--skip-files "/usr/local/bin/terraform,/usr/local/bin/terragrunt,/usr/local/bin/tofu,/usr/local/bin/tflint,/usr/local/bin/terraform-docs,/usr/local/bin/trivy,/usr/local/bin/kubectl,/usr/local/bin/helm,/usr/local/bin/k9s" \
		$(IMAGE_NAME):k8s-$(TAG)

.PHONY: run-k8s
run-k8s: ## Run k8s image interactively
	docker run --rm -it $(IMAGE_NAME):k8s-$(TAG) bash

.PHONY: debug-k8s
debug-k8s: build-k8s run-k8s ## Build and run k8s image

.PHONY: clean-k8s
clean-k8s: ## Remove local k8s Docker image
	docker rmi $(IMAGE_NAME):k8s-$(TAG) || true

# ------------------------------------------------------------------------------
# Help
# ------------------------------------------------------------------------------

.PHONY: help
help: ## Show this help
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
	awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-16s\033[0m %s\n", $$1, $$2}'