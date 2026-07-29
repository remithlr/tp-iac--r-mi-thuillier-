SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := help

.PHONY: help lint secrets clean

help: ## Affiche cette aide
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
	awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

lint: ## Lance les verifications
	pre-commit run --all-files

secrets: ## Scanne l'historique pour des secrets
	gitleaks detect --source . --verbose

clean: ## Nettoie les fichiers temporaires
	rm -rf .terraform *.tfstate*
