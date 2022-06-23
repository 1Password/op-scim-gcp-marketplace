APP_ID ?= 1password/op-scim-bridge
TAG ?= latest
PUBLIC_TAG ?= latest
$(info ---- TAG = $(TAG))
$(info ---- PUBLIC_TAG = $(PUBLIC_TAG))

include ../tools/gcloud.Makefile
include ../tools/var.Makefile

APP_IMAGE ?= $(REGISTRY)/op-scim-bridge:$(TAG)
APP_DEPLOYER_IMAGE ?= $(REGISTRY)/op-scim-bridge/deployer:$(TAG)
APP_REDIS_IMAGE ?= $(REGISTRY)/op-scim-bridge/redis:$(TAG)
APP_GCS_PATH ?= $(GCS_URL)/$(APP_ID)/$(TAG)
CHART_NAME ?= op-scim-bridge
NAME ?= op-scim-bridge
APP_PARAMETERS ?= { \
	"name": "$(NAME)", \
	"namespace": "$(NAMESPACE)" \
}
APP_TEST_PARAMETERS ?= {}

include ../tools/app.Makefile

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
	docker build \
		--build-arg PUBLIC_TAG="$(PUBLIC_TAG)" \
		--tag "$(APP_IMAGE)" \
		.
	# docker pull "1password/scim:v$(PUBLIC_TAG)"
	# docker tag "1password/scim:v$(PUBLIC_TAG)" "$(REGISTRY)/op-scim-bridge:$(TAG)"
	docker push "$(APP_IMAGE)"
	@touch "$@"

.build/op-scim/op-scim-redis: .build/var/REGISTRY \
							  .build/var/TAG \
							  | .build/op-scim
	$(call print_target, $@)
	docker build \
		--file redis/Dockerfile \
		--tag "$(APP_REDIS_IMAGE)" \
		.
	docker push "$(APP_REDIS_IMAGE)"
	@touch "$@"

app/test:
	mpdev /scripts/verify --deployer=gcr.io/op-scim-bridge/op-scim-bridge/deployer:${TAG}
