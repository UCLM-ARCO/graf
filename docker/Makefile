MAKEFLAGS += --warn-undefined-variables
HOW_TO_LOGIN=https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-docker-registry
GITHUB_TOKEN=~/.github-token-packages

HUB=docker.pkg.github.com
VERSION=latest
NAME=graf
IMAGE=${HUB}/uclm-arco/${NAME}/${NAME}:${VERSION}

login:
	@test ! -z "${GITHUB_USERNAME}" || (echo "ERROR: Define var GITHUB_USERNAME"; false)
	@test ! -f "${GITHUB_TOKEN}" || (echo "ERROR: Need a token. See $${HOW_TO_LOGIN}"; false)
	@cat ${GITHUB_TOKEN} | docker login ${HUB} -u ${GITHUB_USERNAME} --password-stdin

image-uri:
	@echo ${IMAGE}

build:
	docker build . -t ${NAME}

push: build login
	docker tag ${NAME} ${IMAGE}
	docker push ${IMAGE}

version:
	docker run -v $(shell dirname $$PWD):/host ${NAME} dpkg -l graf
