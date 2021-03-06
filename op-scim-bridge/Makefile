APP_ID ?= 1password/op-scim-bridge
TAG ?= latest
PUBLIC_TAG ?= latest
$(info ---- TAG = $(TAG))
$(info ---- PUBLIC_TAG = $(PUBLIC_TAG))

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

include ../tools/app_v2.Makefile

app/build:: .build/op-scim/deployer \
			.build/op-scim/op-scim-redis \
			.build/op-scim/op-scim-bridge

.build/op-scim: | .build
	mkdir -p "$@"

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

.build/op-scim/op-scim-bridge: .build/var/REGISTRY \
							   .build/var/TAG \
							   .build/var/PUBLIC_TAG \
							   | .build/op-scim
	$(call print_target, $@)
	docker pull "1password/scim:v$(PUBLIC_TAG)"
	docker tag "1password/scim:v$(PUBLIC_TAG)" "$(REGISTRY)/op-scim-bridge:$(TAG)"
	docker push "$(REGISTRY)/op-scim-bridge:$(TAG)"
	@touch "$@"

.build/op-scim/op-scim-redis: .build/var/REGISTRY \
							  .build/var/TAG \
							  | .build/op-scim
	$(call print_target, $@)
	docker pull gcr.io/cloud-marketplace-containers/google/redis4
	docker tag gcr.io/cloud-marketplace-containers/google/redis4 \
		"$(REGISTRY)/op-scim-bridge/redis:$(TAG)"
	docker push "$(REGISTRY)/op-scim-bridge/redis:$(TAG)"
	@touch "$@"

app/test:
	mpdev /scripts/verify --deployer=gcr.io/op-scim-bridge/op-scim-bridge/deployer:${TAG}
