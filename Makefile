# ==================================================================================== #
# HELPERS
# ==================================================================================== #
## make help OR make: Show the possible commands within the make file
.PHONY: help
help:
	@echo 'List of available commands:'
	@sed -n 's/^##//p' ${MAKEFILE_LIST} | column -t -s ':' |  sed -e 's/^/ /'

# ==================================================================================== #
# QUALITY CONTROL
# ==================================================================================== #
GIT_COMMIT := $(shell git rev-list -1 HEAD)
## serve: serve the application using docker-compose
.PHONY: serve
serve:
	@echo ----> on head ${GIT_COMMIT}
	@export DOCKER_DEFAULT_PLATFORM=linux/amd64
	docker compose up --build

## tidy: clean up after using docker-compose
.PHONY: tidy
tidy:
	docker compose down --rmi all

## test: test the system
.PHONY: health
health:
	curl "http://localhost:80/"

## test: test the system
.PHONY: test
test:
	sh test.sh