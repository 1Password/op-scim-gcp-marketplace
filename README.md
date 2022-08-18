# 1Password SCIM Bridge (op-scim-bridge) on GCP

This repository contains the Helm chart used to build the 1Password SCIM Bridge - Google Cloud Marketplace App.

The Helm chart uses the [1Password/op-scim-helm](https://github.com/1Password/op-scim-helm) chart as a base and overrides defualt values required for deployment
on the Google Cloud Platform.

To work with this deployment bundle, you will need to have the following tools installed:
- [Helm](https://helm.sh/docs/intro/install/)
- `mpdev` development tool from Google. Installation and usage instructions are detailed below.

## Package Structure

```
.
├── op-scim-bridge
│   ├── apptest
│   │   └── deployer
│   │       ├── op-scim-bridge
│   │       │   ├── templates
│   │       │   │   └── tester.yaml
│   │       │   └── values.yaml
│   │       └── schema.yaml
│   ├── chart
│   │   └── op-scim-bridge-mp
│   │       ├── charts
│   │       │   ├── op-scim-bridge-M.m.p.tgz
│   │       ├── templates
│   │       │   ├── application.yaml
│   │       │   └── deployer-cleanup.yaml
│   │       ├── Chart.yaml
│   │       ├── Chart.lock
│   │       ├── logo.png
│   │       ├── README.md
│   │       └── values.yaml
│   ├── deployer
│   │   └── Dockerfile
│   ├── Makefile
│   └── schema.yaml
└── README.md
```

The `op-scim-bridge` package is further broken down into five components:

- `apptest` - instructions for building the verification test image
- `chart` - the main chart (Kubernetes package) for building and running the SCIM Bridge. More information can be found in the chart [README.md](./op-scim-bridge/chart/op-scim-bridge-mp/README.md)
- `deployer` - the GCP deployer which creates and runs the chart in GCP. This mechanism is maintained by GCP, and used by our package.
- `Makefile` - our makefile used to create new images. The three components (deployer, redis, op-scim-bridge) get built separately and pushed to distinct subdirectories of the op-scim-bridge GCP image.
- `schema.yaml` - defines the top level variables that will be queried in the marketplace deployer.

## Updating the SCIM bridge version

Updating the version of the SCIM bridge involves a few steps that are described in the op-scim-bridge-mp Chart README.md.

See [Updating the SCIM bridge version](./op-scim-bridge/chart/op-scim-bridge-mp/README.md#updating-the-scim-bridge-version) for details.

Note that if there is a major version change of the bundled dependencies (i.e. the SCIM bridge or bitnami/redis), then we should also update the major version number of the following corresponding variables in the [op-scim-bridge/push-dep-image-tags.sh](op-scim-bridge/push-dep-image-tags.sh) script:
- `OP_SCIM_BRIDGE_HELM_VERSION`
- `BITNAMI_REDIS_HELM_VERSION`

## Building a New Image

Using the makefile, one can create a push a new image to the Google Container Registry (GCR). To do so, one must declare environment variables:

- `REGISTRY` - the Google Cloud Registry you are building for
- `TAG` - private tag/version. Can be useful for testing, but this should mirror
the `appVersion` of the [op-scim-bridge-mp](./op-scim-bridge/chart/op-scim-bridge-mp/Chart.yaml) chart when creating a release.


To build a release build with version 2.4.1:

```bash
REGISTRY="YOUR_REGISTRY" TAG=2.4.1 make app/build
```

Alternatively, to build a testing build, you can specify a testing tag:

```bash
REGISTRY="YOUR_REGISTRY" TAG=test-vendoring make app/build
```

## `mpdev`

`mpdev` is a command line tool from the marketplace tool which allows one to build, install, and verify a GCP Marketplace application.

A pre-requisite to using `mpdev` is an existing `kubectl` installation with access to your GCP Kubernetes cluster.

Any reference to `--deployer=gcr.op/op-scim-bridge/op-scim-bridge/deployer:TAG` is referencing the constructed docker image. If not present locally, this will be pulled from the Google Container Registry.

Tags are updated regularly and may vary. The `latest` tag is not always updated, so be sure to check dates when pulling. For illustrative purposes, these examples will use the `latest` tag.

### Tool Installation

The installation process concludes with a PATH-able binary somewhere on your machine through running a docker image locally. Feel free to customise to your setup, but this was what worked for me:

```bash
BIN_FILE="/usr/local/bin/mpdev"

docker run gcr.io/cloud-marketplace-tools/k8s/dev cat /scripts/dev > "$BIN_FILE"
```

The same command can be used to update your version of `mpdev`.

You can validate your installation by running `mpdev doctor`.

## Install

It is possible to use `mpdev` to install our application on your Kubernetes cluster on GCP. This allows you to test our application outside of the marketplace.

As defined in [schema.yaml](./op-scim-bridge/schema.yaml) our application requires the following arguments:
- `name`
- `namespace`
- `accountDomain`
 
These parallel the values chosen in the user interface when deploying from the Marketplace.

```bash
mpdev install --deployer=gcr.io/op-scim-bridge/op-scim-bridge/deployer:latest --parameters='{"name": "mpdev", "namespace": "default", "accountDomain": "testing.1password.com" }'
```

Once this process completes, you can examine your new SCIM Bridge on GCP using kubectl or via the GCP Console in the browser.

## Verify

`mpdev` verify runs the verification test image created from the `apptest` folder. This is set at a deployer tag.

Run verification like so:

```bash
mpdev verify --deployer=gcr.io/op-scim-bridge/op-scim-bridge/deployer:latest
```

Or by using the Make command (from path `./op-scim-bridge`):

```bash
TAG=2.4.1 make app/test
```

The output is very long and rather hard to read, but all the components of what is happening are in there. Near the end you should see our simple `/ping` curl verification test happen.

The `mpdev` logs can be accessed via `$HOME/.mpdev_logs`.

## More

A full installation guide can be found here: [GCP MPDev Reference](https://github.com/GoogleCloudPlatform/marketplace-k8s-app-tools/blob/master/docs/mpdev-references.md)
