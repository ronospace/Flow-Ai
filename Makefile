SHELL := /bin/bash

.PHONY: help bootstrap clean fmt analyze test lint doctor ci tree secrets

help:
	@echo "Flow Ai repo automation"
	@echo ""
	@echo "Targets:"
	@echo "  make bootstrap   Install flutter deps"
	@echo "  make fmt         Format Dart code"
	@echo "  make analyze     Run static analysis"
	@echo "  make test        Run tests"
	@echo "  make lint        Run fmt + analyze + test"
	@echo "  make doctor      Flutter doctor"
	@echo "  make ci          CI-like run (fmt check + analyze + test)"
	@echo "  make tree        Show repo structure summary"
	@echo "  make secrets     Scan repo for secrets (gitleaks)"

bootstrap:
	@command -v flutter >/dev/null || (echo "❌ flutter not found. Install Flutter first."; exit 1)
	flutter --version
	flutter pub get

doctor:
	flutter doctor -v

clean:
	flutter clean
	rm -rf .dart_tool build

fmt:
	dart format .

analyze:
	flutter analyze

test:
	flutter test

lint: fmt analyze test

ci:
	@echo "CI run: format check + analyze + test"
	dart format --output=none --set-exit-if-changed .
	flutter analyze
	flutter test

tree:
	@echo "Top-level:"
	@ls -la
	@echo ""
	@echo "Directories:"
	@find . -maxdepth 1 -type d -not -path '.' -print

secrets:
	@command -v gitleaks >/dev/null || (echo "❌ gitleaks not found. Install with: brew install gitleaks"; exit 1)
	gitleaks detect --source . --redact --no-banner
