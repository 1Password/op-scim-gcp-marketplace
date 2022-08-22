#! /bin/sh

if ! command -v helm &> /dev/null
then
  echo "helm could not be found"
  exit 1
fi

if ! command -v jq &> /dev/null
then
  echo "jq could not be found"
  exit 1
fi

echo "adding 1password Helm repo"
helm repo add 1password https://1password.github.io/op-scim-helm
helm repo update 1password

echo "adding bitnami Helm repo"
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update bitnami

# OP_SCIM_BRIDGE_HELM_VERSION should the "op-scim-bridge" dependency version in 
# https://github.com/1Password/op-scim-gcp-marketplace/blob/master/op-scim-bridge/chart/op-scim-bridge-mp/Chart.yaml
if [[ -z "${OP_SCIM_BRIDGE_HELM_VERSION}" ]]; then
  OP_SCIM_BRIDGE_HELM_VERSION="^2"
  echo "OP_SCIM_BRIDGE_HELM_VERSION not set; using default ${OP_SCIM_BRIDGE_HELM_VERSION}"
fi

OP_SCIM_BRIDGE_REPO="1password/scim"
OP_SCIM_BRIDGE_TAG=$(helm search repo 1password/op-scim-bridge --version ${OP_SCIM_BRIDGE_HELM_VERSION} -o json | jq -r '.[] | .app_version')
OP_SCIM_BRIDGE_IMAGE=${OP_SCIM_BRIDGE_REPO}:${OP_SCIM_BRIDGE_TAG}
echo "scim bridge image: ${OP_SCIM_BRIDGE_IMAGE}"

# BITNAMI_REDIS_HELM_VERSION should match the "redis" dependency version in 
# https://github.com/1Password/op-scim-helm/blob/main/charts/op-scim-bridge/Chart.yaml
if [[ -z "${BITNAMI_REDIS_HELM_VERSION}" ]]; then
  BITNAMI_REDIS_HELM_VERSION="^16"
  echo "BITNAMI_REDIS_HELM_VERSION not set; using default ${BITNAMI_REDIS_HELM_VERSION}"
fi

BITNAMI_REDIS_REPO="bitnami/redis"
BITNAMI_REDIS_TAG=$(helm search repo bitnami/redis --version ${BITNAMI_REDIS_HELM_VERSION} -o json | jq -r '.[] | .app_version')
BITNAMI_REDIS_IMAGE=${BITNAMI_REDIS_REPO}:${BITNAMI_REDIS_TAG}
echo "redis image: ${BITNAMI_REDIS_IMAGE}"

echo "pull docker images"
docker pull ${OP_SCIM_BRIDGE_IMAGE}
docker pull ${BITNAMI_REDIS_IMAGE}

echo "tag docker images"
docker tag ${OP_SCIM_BRIDGE_IMAGE} ${REGISTRY}/op-scim-bridge:${TAG}
docker tag ${BITNAMI_REDIS_IMAGE} ${REGISTRY}/op-scim-bridge/redis:${TAG}

echo "push docker images"
docker push ${REGISTRY}/op-scim-bridge:${TAG}
docker push ${REGISTRY}/op-scim-bridge/redis:${TAG}
