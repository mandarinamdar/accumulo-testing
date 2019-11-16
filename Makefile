DOCKER_REGISTRY		?= mcinfra.azurecr.io
IMAGE_NAME			?= accumulo-testing

GIT_BRANCH         = ${shell git rev-parse --abbrev-ref HEAD}
GIT_COMMIT         = ${shell git rev-parse HEAD}
GIT_SHA            = ${shell git rev-parse --short HEAD}

DOCKER_FILE            = Dockerfile
DOCKER_VERSION_LATEST  = $(subst /,-,${GIT_BRANCH}).${GIT_SHA}
IMAGE_LATEST           = ${DOCKER_REGISTRY}/${IMAGE_NAME}:${DOCKER_VERSION_LATEST}
HADOOP_HOME            = /opt/muchos/install/hadoop-3.2.1
HADOOP_USER_NAME       = centos
KEYVAULT_SECRET_NAME   = longhaul-100-ikey


.PHONY: build
build:
	rm -rf target/
	./bin/build
	test -f conf/accumulo-client.properties || touch conf/accumulo-client.properties
	@docker build --rm --no-cache --build-arg HADOOP_HOME=${HADOOP_HOME} --build-arg HADOOP_USER_NAME=${HADOOP_USER_NAME} -t ${IMAGE_LATEST} -f ./Dockerfile .

.PHONY: quickbuild
quickbuild:
	rm -rf target/
	./bin/build
	test -f conf/accumulo-client.properties || touch conf/accumulo-client.properties
	@docker build --rm --build-arg HADOOP_HOME=${HADOOP_HOME} --build-arg HADOOP_USER_NAME=${HADOOP_USER_NAME} -t ${IMAGE_LATEST} -f ./Dockerfile .

.PHONY: push
push:
	@docker push ${IMAGE_LATEST}

.PHONY: helm-install
helm-install:
	@ikey=$$(az keyvault secret show --name ${KEYVAULT_SECRET_NAME} --vault-name mcinfra-kv --query value -o tsv); \
	helm install healthprobe ./helm/healthprobe --values ./helm/deployed-values.yaml --set secrets.INSTRUMENTATIONKEY=$$ikey -n hp

.PHONY: helm-upgrade
helm-upgrade:
	@ikey=$$(az keyvault secret show --name ${KEYVAULT_SECRET_NAME} --vault-name mcinfra-kv --query value -o tsv); \
	helm upgrade healthprobe ./helm/healthprobe --values ./helm/deployed-values.yaml --set secrets.INSTRUMENTATIONKEY=$$ikey -n hp

.PHONY: helm-info
helm-info:
	@helm get all healthprobe -n hp

.PHONY: helm-delete
helm-delete:
	@helm delete healthprobe -n hp

.PHONY: info
info:
	@echo "Git Branch:       ${GIT_BRANCH}"
	@echo "Git Commit:       ${GIT_COMMIT}"
	@echo "Git Commit short: ${GIT_SHA}"
	@echo "Registry:         ${DOCKER_REGISTRY}"
	@echo "Image:            ${IMAGE_LATEST}"