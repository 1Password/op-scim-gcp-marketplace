ARG MARKETPLACE_TOOLS_TAG
FROM gcr.io/cloud-marketplace/google/debian12 AS build

RUN apt-get update \
    && apt-get install -y --no-install-recommends gettext

ADD chart/op-scim-bridge-mp /tmp/chart
RUN cd /tmp && tar -czvf /tmp/op-scim-bridge.tar.gz chart

ADD apptest/deployer/op-scim-bridge /tmp/test/chart
RUN cd /tmp/test \
    && tar -czvf /tmp/test/op-scim-bridge.tar.gz chart/

ADD schema.yaml /tmp/schema.yaml

ARG REGISTRY
ARG TAG

RUN cat /tmp/schema.yaml \
    | env -i "REGISTRY=$REGISTRY" "TAG=$TAG" envsubst \
    > /tmp/schema.yaml.new \
    && mv /tmp/schema.yaml.new /tmp/schema.yaml

ADD apptest/deployer/schema.yaml /tmp/apptest/schema.yaml
RUN cat /tmp/apptest/schema.yaml \
    | env -i "REGISTRY=$REGISTRY" "TAG=$TAG" envsubst \
    > /tmp/apptest/schema.yaml.new \
    && mv /tmp/apptest/schema.yaml.new /tmp/apptest/schema.yaml

FROM gcr.io/cloud-marketplace-tools/k8s/deployer_helm:$MARKETPLACE_TOOLS_TAG

RUN apt-get update \
	&& apt-get -y upgrade \
	&& rm -rf /var/lib/apt/lists/*

COPY --from=build /tmp/op-scim-bridge.tar.gz /data/chart/
COPY --from=build /tmp/test/op-scim-bridge.tar.gz /data-test/chart/
COPY --from=build /tmp/apptest/schema.yaml /data-test/
COPY --from=build /tmp/schema.yaml /data/

ENV WAIT_FOR_READY_TIMEOUT 300
ENV TESTER_TIMEOUT 300
