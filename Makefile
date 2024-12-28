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
IMAGE_NAME := ngshiheng/cafireshistorydb
TAG_DATE := $(shell date -u +%Y%m%d)

.PHONY: docker-build
docker-build:	## build datasette docker image.
	@[ -f $(SQLITE_FILE) ] && echo "File $(SQLITE_FILE) exists." || { echo "File $(SQLITE_FILE) does not exist." >&2; exit 1; }
	@if [ -z $(DOCKER) ]; then echo "Docker could not be found. See https://docs.docker.com/get-docker/"; exit 2; fi
	@if [ -z $(DATASETTE) ]; then echo "Datasette could not be found. See https://docs.datasette.io/en/stable/installation.html"; exit 2; fi
	datasette package $(SQLITE_FILE) --extra-options '--setting allow_download off --setting allow_csv_stream off --setting max_csv_mb 1 --setting default_cache_ttl 86400' --metadata data/metadata.json --install=datasette-cluster-map --install=datasette-hashed-urls --install=datasette-block-robots --tag $(IMAGE_NAME):$(TAG_DATE)
	datasette package $(SQLITE_FILE) --extra-options '--setting allow_download off --setting allow_csv_stream off --setting max_csv_mb 1 --setting default_cache_ttl 86400' --metadata data/metadata.json --install=datasette-cluster-map --install=datasette-hashed-urls --install=datasette-block-robots --tag $(IMAGE_NAME):latest

.PHONY: docker-datasette
docker-datasette:	## run datasette container.
	@if [ -z $(DOCKER) ]; then echo "Docker could not be found. See https://docs.docker.com/get-docker/"; exit 2; fi
	docker stop cafireshistorydb || true && docker rm cafireshistorydb || true
	docker run --rm -p 8001:8001 --name cafireshistorydb $(IMAGE_NAME):latest

.PHONY: docker-push
docker-push:	## build and push docker images to registry.
	@if [ -z $(DOCKER) ]; then echo "Docker could not be found. See https://docs.docker.com/get-docker/"; exit 2; fi
	docker push $(IMAGE_NAME):$(TAG_DATE)
	docker push $(IMAGE_NAME):latest
