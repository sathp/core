# This makefile is designed to handle to common operations involved in developing, build, and testing ACM@UIUC Core

# BASE_PACKAGE should be the name of the go module
# REPO_ROOT will be used to build absolute paths during build or testing stages
BASE_PACKAGE := github.com/acm-uiuc/core
REPO_ROOT := $(shell git rev-parse --show-toplevel)

# Builds all binaries
.PHONY: all
all: core

# Build the ACM@UIUC Core binary
.PHONY: core
core:
	@echo 'Building ACM@UIUC Core'
	@mkdir -p $(REPO_ROOT)/bin
	@go build -o $(REPO_ROOT)/bin/core $(BASE_PACKAGE)
	@echo 'Finished'

# Runs all migration
.PHONY: test-migration
test-migration:
	@echo 'Migrating ACM@UIUC Core Test Database'
	@IS_TEST=true DB_NAME=core-test $(REPO_ROOT)/bin/core -migration all

# Runs all tests
.PHONY: test
test:
	@echo 'Testing ACM@UIUC Core'
	@IS_TEST=true DB_NAME=core-test GITSTORE_BASE_URI=$(REPO_ROOT)/test/data/ go test -p 1 -count=1 github.com/acm-uiuc/core/test/...
	@echo 'Finished'

# Runs the existing binary
.PHONY: run
run:
	@echo 'Starting ACM@UIUC Core'
	@$(REPO_ROOT)/scripts/run.sh

# Formats the repo's golang files
.PHONY: fmt
fmt:
	@go fmt $(BASE_PACKAGE)/...

# Builds the production container
.PHONY: container
container:
	@docker build -t core:prod $(REPO_ROOT)

# Resets the development environment
.PHONY: dev-reset
dev-reset:
	@mysql --host=127.0.0.1 --port=3306 --user=devuser --password=devpass -e 'DROP DATABASE IF EXISTS core;'
	@mysql --host=127.0.0.1 --port=3306 --user=devuser --password=devpass -e 'CREATE DATABASE core;'
	@$(REPO_ROOT)/bin/core -migration all

# Runs the existing binary in dev mode
.PHONY: dev-run
dev-run:
	@echo 'Starting ACM@UIUC Core'
	@$(REPO_ROOT)/scripts/run-dev.sh
