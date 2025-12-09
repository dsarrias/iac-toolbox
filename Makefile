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
	-docker run --rm -i hadolint/hadolint < Dockerfile

.PHONY: build
build: ## Build Docker image
	@echo "--- 🏗️ Building Image ---"
	docker build -t $(IMAGE_NAME):$(TAG) .

.PHONY: dockle
dockle: ## Audit image best practices (Dockle)
	@echo "--- 🛡️ Running Dockle ---"
	-docker run --rm \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v "$(shell pwd)/.dockleignore:/.dockleignore" \
		goodwithtech/dockle:latest --exit-code 1 $(IMAGE_NAME):$(TAG)

.PHONY: trivy
trivy: ## Scan for vulnerabilities (Trivy)
	@echo "--- 🦠 Running Trivy ---"
	-docker run --rm \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v "$(shell pwd)/.trivyignore:/.trivyignore" \
		aquasec/trivy:latest image \
		--severity CRITICAL,HIGH --exit-code 1 --ignore-unfixed \
		$(IMAGE_NAME):$(TAG)

.PHONY: run
run: ## Run image interactively
	docker run --rm -it $(IMAGE_NAME):$(TAG) bash

.PHONY: debug
debug: build run ## Build and immediately enter container

.PHONY: clean
clean: ## Remove local Docker image
	docker rmi $(IMAGE_NAME):$(TAG) || true

.PHONY: help
help: ## Show this help
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
	awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-16s\033[0m %s\n", $$1, $$2}'