.PHONY: help validate start stop restart logs clean migrate-volumes test lint security config config-% pre-commit-install pre-commit-run

# Default target
help:
	@echo "Homeserver Docker Stack Management"
	@echo ""
	@echo "Available targets:"
	@echo "  make config            - Render all templates (.tmpl) using environment variables"
	@echo "  make validate          - Validate all compose files and env files"
	@echo "  make start-core        - Start core stacks (network, dbs, auth)"
	@echo "  make start-all         - Start all stacks"
	@echo "  make start-<stack>     - Start specific stack (e.g., make start-photos)"
	@echo "  make stop-all          - Stop all stacks"
	@echo "  make stop-<stack>      - Stop specific stack"
	@echo "  make restart-<stack>   - Restart specific stack"
	@echo "  make logs-<stack>      - View logs for specific stack"
	@echo "  make ps                - Show running containers"
	@echo "  make lint              - Run all linting checks (via pre-commit)"
	@echo "  make pre-commit-install - Install pre-commit hooks"
	@echo "  make security          - Run security scans"
	@echo "  make test              - Run all validation tests"
	@echo "  make clean             - Remove stopped containers and unused volumes"
	@echo "  make migrate-volumes   - Migrate volumes to new names"
	@echo ""

# Configuration rendering
config:
	@echo "=== Rendering all templates ==="
	@for stack in $(ALL_STACKS); do $(MAKE) config-$$stack; done

config-%:
	@if [ -d $* ]; then \
		echo "Rendering templates for $*..."; \
		for tmpl in $*/*.tmpl; do \
			if [ -f "$$tmpl" ]; then \
				output=$${tmpl%.tmpl}; \
				set -a; \
				[ -f .env.global ] && . ./.env.global; \
				[ -f $*/.env ] && . ./$*/.env; \
				envsubst "$$(printf '$${%s} ' $$(env | cut -d= -f1))" < "$$tmpl" > "$$output"; \
				set +a; \
				echo "  ✓ Rendered $$output"; \
			fi; \
		done; \
	fi


# Core stacks
CORE_STACKS := network dbs auth

# Optional stacks
OPTIONAL_STACKS := monitoring photos media bookmarks dashboard notes

# All stacks
ALL_STACKS := $(CORE_STACKS) $(OPTIONAL_STACKS) documents chat finance notifications containers wiki

# Validation
validate: validate-compose validate-env validate-yaml

validate-compose:
	@echo "=== Validating Docker Compose files ==="
	@for stack in $(ALL_STACKS); do \
		if [ -f $$stack/compose.yaml ]; then \
			echo "Validating $$stack..."; \
			cd $$stack && docker compose config > /dev/null && cd ..; \
		fi; \
	done
	@echo "✓ All compose files valid"

validate-env:
	@echo "=== Validating environment files ==="
	@.github/scripts/validate-env.sh

validate-yaml:
	@echo "=== Linting YAML files ==="
	@yamllint -c .yamllint.yml . || echo "Install yamllint: pip install yamllint"

# Pre-commit
# Use command -v or check ~/.local/bin/pre-commit
PRE_COMMIT := $(shell command -v pre-commit 2> /dev/null || echo "$(HOME)/.local/bin/pre-commit")

pre-commit-install:
	@if [ -x "$(PRE_COMMIT)" ]; then \
		$(PRE_COMMIT) install; \
		echo "✓ Pre-commit hooks installed"; \
	else \
		echo "Error: pre-commit not found. Please install it:"; \
		echo "  pip install --user pre-commit"; \
		echo "  Then ensure ~/.local/bin is in your PATH"; \
		exit 1; \
	fi

pre-commit-run:
	@if [ -x "$(PRE_COMMIT)" ]; then \
		$(PRE_COMMIT) run --all-files; \
	else \
		echo "Pre-commit not found, exiting..."; \
	fi

# Linting
lint: pre-commit-run

# Security
security: security-secrets security-scan

security-secrets:
	@echo "=== Scanning for secrets ==="
	@gitleaks detect --config .gitleaks.toml || echo "Install gitleaks: https://github.com/gitleaks/gitleaks"

security-scan:
	@echo "=== Running security scan ==="
	@trivy config . || echo "Install trivy: https://github.com/aquasecurity/trivy"

# Test (runs all checks)
test: validate lint security
	@echo "✓ All tests passed"

# Start operations
start-core:
	@echo "=== Starting core stacks ==="
	@for stack in $(CORE_STACKS); do \
		echo "Starting $$stack..."; \
		cd $$stack && docker compose up -d && cd ..; \
		sleep 3; \
	done
	@echo "✓ Core stacks started"

start-all: start-core
	@echo "=== Starting optional stacks ==="
	@for stack in $(OPTIONAL_STACKS); do \
		echo "Starting $$stack..."; \
		cd $$stack && docker compose up -d && cd ..; \
	done
	@echo "✓ All stacks started"

# Individual stack operations
start-%:
	@echo "Starting $*..."
	@cd $* && docker compose up -d

stop-%:
	@echo "Stopping $*..."
	@cd $* && docker compose down

restart-%:
	@echo "Restarting $*..."
	@cd $* && docker compose restart

logs-%:
	@cd $* && docker compose logs -f

# Stop all
stop-all:
	@echo "=== Stopping all stacks ==="
	@for stack in $(ALL_STACKS); do \
		if [ -f $$stack/compose.yaml ]; then \
			echo "Stopping $$stack..."; \
			cd $$stack && docker compose down && cd ..; \
		fi; \
	done
	@echo "✓ All stacks stopped"

# Container status
ps:
	@docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Image}}"

# Cleanup
clean:
	@echo "=== Cleaning up ==="
	@docker system prune -f
	@echo "✓ Cleanup complete"

clean-volumes:
	@echo "⚠️  This will remove unused volumes. Are you sure? [y/N]"
	@read -r response; \
	if [ "$$response" = "y" ]; then \
		docker volume prune -f; \
	fi

# Update operations
pull-all:
	@echo "=== Pulling latest images ==="
	@for stack in $(ALL_STACKS); do \
		if [ -f $$stack/compose.yaml ]; then \
			echo "Pulling images for $$stack..."; \
			cd $$stack && docker compose pull && cd ..; \
		fi; \
	done
	@echo "✓ All images pulled"

update-%: pull-% restart-%
	@echo "✓ $* updated"

pull-%:
	@cd $* && docker compose pull

# Backup operations
backup-env:
	@echo "=== Backing up environment files ==="
	@mkdir -p backups/env-$$(date +%Y%m%d-%H%M%S)
	@cp .env.global backups/env-$$(date +%Y%m%d-%H%M%S)/
	@for stack in $(ALL_STACKS); do \
		if [ -f $$stack/.env ]; then \
			cp $$stack/.env backups/env-$$(date +%Y%m%d-%H%M%S)/$$stack.env; \
		fi; \
	done
	@echo "✓ Environment files backed up"

# Development helpers
dev-network:
	@make start-network start-dbs start-auth

dev-full:
	@make start-core start-monitoring start-dashboard
