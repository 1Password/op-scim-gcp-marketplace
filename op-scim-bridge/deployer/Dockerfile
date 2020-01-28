FROM debian:latest AS build

RUN apt-get update \
    && apt-get install -y --no-install-recommends gettext

ADD chart/op-scim /tmp/chart
RUN cd /tmp && tar -czvf /tmp/op-scim-bridge.tar.gz chart

ADD apptest/deployer/op-scim-bridge /tmp/test/chart
RUN cd /tmp/test \
    && tar -czvf /tmp/test/op-scim-bridge.tar.gz chart/

ADD schema.yaml /tmp/schema.yaml
ADD apptest/deployer/schema.yaml /tmp/apptest/schema.yaml

FROM gcr.io/cloud-marketplace-tools/k8s/deployer_helm/onbuild:0.9.10
COPY --from=build /tmp/op-scim-bridge.tar.gz /data/chart/
COPY --from=build /tmp/test/op-scim-bridge.tar.gz /data-test/chart/
COPY --from=build /tmp/apptest/schema.yaml /data-test/
COPY --from=build /tmp/schema.yaml /data/
