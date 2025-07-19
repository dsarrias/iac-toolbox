# Variables
BUILD_TAG ?= iac-toolbox

# Settings
.SILENT:
.DEFAULT_GOAL := help

# Targets
.PHONY: build
build: ## Build Docker image with local tag
	docker build --tag $(BUILD_TAG):local .

.PHONY: run
run: ## Run Docker image interactively with bash
	docker run --rm -it $(BUILD_TAG):local bash

.PHONY: test
test: build run ## Build the image and enter container

.PHONY: clean
clean: ## Remove local Docker image
	docker rmi $(BUILD_TAG):local || true

.PHONY: help
help: ## Show this help
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
	awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-16s\033[0m %s\n", $$1, $$2}'
