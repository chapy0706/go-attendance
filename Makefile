SHELL := /bin/bash

.PHONY: verify
verify:
	@echo "TODO: run format, lint, typecheck, test"

.PHONY: evidence
evidence:
	@mkdir -p out/evidence
	@echo "TODO: save verification logs to out/evidence"

.PHONY: dev
dev:
	@echo "TODO: start local development environment"

.PHONY: db-migrate
db-migrate:
	@echo "TODO: run database migrations"
