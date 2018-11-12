include ../vendor/marketplace-tools/app.Makefile
include ../vendor/marketplace-tools/crd.Makefile
include ../vendor/marketplace-tools/gcloud.Makefile
include ../vendor/marketplace-tools/marketplace.Makefile
include ../vendor/marketplace-tools/ubbagent.Makefile
include ../vendor/marketplace-tools/var.Makefile


TAG ?= latest
$(info ---- TAG = $(TAG))

APP_DEPLOYER_IMAGE ?= gcr.io/agilebits-public/agilebits/op-scim-bridge/deployer:$(TAG)
NAME ?= op-scim
APP_PARAMETERS ?= { \
  "APP_INSTANCE_NAME": "$(NAME)", \
  "NAMESPACE": "$(NAMESPACE)" \
}
APP_TEST_PARAMETERS ?= {}


app/build:: .build/op-scim/deployer \
            .build/op-scim/redis \
            .build/op-scim/op-scim


.build/op-scim: | .build
	mkdir -p "$@"


.build/op-scim/deployer: deployer/* \
								$(shell find chart -type f) \
                           		schema.yaml \
                           		.build/var/APP_DEPLOYER_IMAGE \
								.build/var/REGISTRY \
								.build/var/TAG \
								| .build/op-scim
	docker build \
	    --build-arg REGISTRY="gcr.io/agilebits-public/agilebits" \
	    --build-arg TAG="$(TAG)" \
	    --tag "$(APP_DEPLOYER_IMAGE)" \
	    -f deployer/Dockerfile \
	    .
	docker push "$(APP_DEPLOYER_IMAGE)"
	@touch "$@"


.build/op-scim/op-scim: .build/var/REGISTRY \
						.build/var/TAG \
						| .build/op-scim
	docker pull gcr.io/b5-playground/op-scim:webapp
	docker tag gcr.io/b5-playground/op-scim:webapp "gcr.io/agilebits-public/agilebits/op-scim-bridge/op-scim:$(TAG)"
	docker push "gcr.io/agilebits-public/agilebits/op-scim-bridge/op-scim:$(TAG)"
	@touch "$@"


.build/op-scim/redis: .build/var/REGISTRY \
						.build/var/TAG \
						| .build/op-scim
	docker pull gcr.io/cloud-marketplace-containers/google/redis4
	docker tag gcr.io/cloud-marketplace-containers/google/redis4 "gcr.io/agilebits-public/agilebits/op-scim-bridge/redis:$(TAG)"
	docker push "gcr.io/agilebits-public/agilebits/op-scim-bridge/redis:$(TAG)"
	@touch "$@"
