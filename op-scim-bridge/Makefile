APP_ID ?= 1password/op-scim-bridge
TAG ?= latest

include ../tools/gcloud.Makefile
include ../tools/var.Makefile

APP_DEPLOYER_IMAGE ?= $(REGISTRY)/op-scim-bridge/deployer:$(TAG)
APP_GCS_PATH ?= $(GCS_URL)/$(APP_ID)/$(TAG)
CHART_NAME ?= op-scim-bridge
NAME ?= op-scim-bridge
APP_PARAMETERS ?= { \
	"name": "$(NAME)", \
	"namespace": "$(NAMESPACE)" \
}
APP_TEST_PARAMETERS ?= {}

include ../tools/app.Makefile

app/build:: .build/check/docker .build/op-scim/deployer .build/op-scim/deps
	@echo "\nimage tags pushed:"
	@echo "deployer: $(APP_DEPLOYER_IMAGE)"
	@echo "scim bridge: ${REGISTRY}/op-scim-bridge:${TAG}"
	@echo "redis: ${REGISTRY}/op-scim-bridge/redis:${TAG}"

.build/op-scim/deployer: .build/var/APP_DEPLOYER_IMAGE \
						 $(shell find chart -type f) \
						 .build/var/MARKETPLACE_TOOLS_TAG \
						 .build/var/REGISTRY \
						 .build/var/TAG \
						 apptest/deployer/* \
						 deployer/* \
						 schema.yaml \
						 | .build/op-scim
	$(call print_target, $@)
	docker build \
		--build-arg REGISTRY="$(REGISTRY)/op-scim-bridge" \
		--build-arg TAG="$(TAG)" \
		--build-arg MARKETPLACE_TOOLS_TAG="$(MARKETPLACE_TOOLS_TAG)" \
		--tag "$(APP_DEPLOYER_IMAGE)" \
		-f deployer/Dockerfile \
		.
	docker push "$(APP_DEPLOYER_IMAGE)"
	@touch "$@"

.build/check/docker:
	./check-docker.sh

.build/op-scim/deps:
	./push-dep-image-tags.sh

app/test:
	mpdev /scripts/verify --deployer=gcr.io/op-scim-bridge/op-scim-bridge/deployer:${TAG}

.build/op-scim:
	mkdir -p .build/op-scim
