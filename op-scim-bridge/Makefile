
TAG ?= latest
PUBLIC_TAG ?= latest
$(info ---- TAG = $(TAG))
$(info ---- PUBLIC_TAG = $(PUBLIC_TAG))

include ../gcloud.Makefile
include ../var.Makefile

APP_DEPLOYER_IMAGE ?= $(REGISTRY)/op-scim-bridge/deployer:$(TAG)
NAME ?= op-scim-bridge
APP_PARAMETERS ?= { \
  "name": "$(NAME)", \
  "namespace": "$(NAMESPACE)" \
}
APP_TEST_PARAMETERS ?= {}

include ../app.Makefile

app/build:: .build/op-scim/deployer \
            .build/op-scim/op-scim-redis \
            .build/op-scim/op-scim-bridge


.build/op-scim: | .build
	mkdir -p "$@"


.build/op-scim/deployer: deployer/* \
								$(shell find chart -type f) \
                           		schema.yaml \
                           		.build/var/APP_DEPLOYER_IMAGE \
								.build/var/REGISTRY \
								.build/var/TAG \
								.build/var/PUBLIC_TAG \
								| .build/op-scim
	docker build \
	    --build-arg REGISTRY="$(REGISTRY)/op-scim-bridge" \
	    --build-arg TAG="$(TAG)" \
	    --build-arg PUBLIC_TAG="$(PUBLIC_TAG)" \
	    --tag "$(APP_DEPLOYER_IMAGE)" \
	    -f deployer/Dockerfile \
	    .
	docker push "$(APP_DEPLOYER_IMAGE)"
	@touch "$@"


.build/op-scim/op-scim-bridge: .build/var/REGISTRY \
							   .build/var/TAG \
							   .build/var/PUBLIC_TAG \
							   | .build/op-scim
	docker tag "1password/scim:v$(PUBLIC_TAG)" "$(REGISTRY)/op-scim-bridge:$(TAG)"
	docker push "$(REGISTRY)/op-scim-bridge:$(TAG)"
	@touch "$@"


.build/op-scim/op-scim-redis: .build/var/REGISTRY \
					  .build/var/TAG \
					  .build/var/PUBLIC_TAG \
					  | .build/op-scim
	docker pull gcr.io/cloud-marketplace-containers/google/redis4
	docker tag gcr.io/cloud-marketplace-containers/google/redis4 \
	    "$(REGISTRY)/op-scim-bridge/redis:$(TAG)"
	docker push "$(REGISTRY)/op-scim-bridge/redis:$(TAG)"
	@touch "$@"
