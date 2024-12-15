DATASETTE := $(shell command -v datasette 2> /dev/null)
DOCKER := $(shell command -v docker 2> /dev/null)
SQLITE_FILE = data/fires.db

.DEFAULT_GOAL := help
##@ Helper
.PHONY: help
help:	## display this help message.
	@echo "Welcome to cafireshistorydb."
	@awk 'BEGIN {FS = ":.*##"; printf "Use make \033[36m<target>\033[0m where \033[36m<target>\033[0m is one of:\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ Usage
.PHONY: scrape
scrape:	## run scraper.
	@python scrape.py

.PHONY: datasette
datasette:	## run datasette.
	@[ -f $(SQLITE_FILE) ] && echo "File $(SQLITE_FILE) exists." || { echo "File $(SQLITE_FILE) does not exist." >&2; exit 1; }
	@if [ -z $(DATASETTE) ]; then echo "Datasette could not be found. See https://docs.datasette.io/en/stable/installation.html"; exit 2; fi
	datasette serve -i $(SQLITE_FILE) --metadata data/metadata.json


##@ Docker
.PHONY: docker-build
docker-build:	## build datasette docker image.
	@[ -f $(SQLITE_FILE) ] && echo "File $(SQLITE_FILE) exists." || { echo "File $(SQLITE_FILE) does not exist." >&2; exit 1; }
	@if [ -z $(DOCKER) ]; then echo "Docker could not be found. See https://docs.docker.com/get-docker/"; exit 2; fi
	@if [ -z $(DATASETTE) ]; then echo "Datasette could not be found. See https://docs.datasette.io/en/stable/installation.html"; exit 2; fi
	datasette package $(SQLITE_FILE) --metadata data/metadata.json --install=datasette-hashed-urls --install=datasette-cluster-map --install=datasette-block-robots --tag ngshiheng/cafireshistorydb:$(shell date +%Y%m%d)
	datasette package $(SQLITE_FILE) --metadata data/metadata.json --install=datasette-hashed-urls --install=datasette-cluster-map --install=datasette-block-robots --tag ngshiheng/cafireshistorydb:latest

.PHONY: docker-datasette
docker-datasette:	## run datasette container.
	@if [ -z $(DOCKER) ]; then echo "Docker could not be found. See https://docs.docker.com/get-docker/"; exit 2; fi
	docker stop cafireshistorydb || true && docker rm cafireshistorydb || true
	docker run --rm -p 8001:8001 --name cafireshistorydb ngshiheng/cafireshistorydb:latest
