FROM gcr.io/cloud-marketplace-tools/k8s/deployer_helm AS build

ADD apptest/deployer/op-scim-bridge /tmp/test/chart
RUN cd /tmp/test \
    && tar -czvf /tmp/test/chart.tar.gz chart/

ADD apptest/deployer/schema.yaml /tmp/apptest/schema.yaml
RUN cat /tmp/apptest/schema.yaml \
    | env -i "REGISTRY=$REGISTRY" "TAG=$TAG" envsubst \
    > /tmp/apptest/schema.yaml.new \
    && mv /tmp/apptest/schema.yaml.new /tmp/apptest/schema.yaml

FROM gcr.io/cloud-marketplace-tools/k8s/deployer_helm/onbuild:0.9.10

COPY --from=build /tmp/test/chart.tar.gz /data-test/chart/
COPY --from=build /tmp/apptest/schema.yaml /data-test/
