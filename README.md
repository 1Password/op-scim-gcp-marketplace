# 1Password SCIM Bridge (op-scim) on GCP

This repository contains the Helm charts used to build the 1Password SCIM Bridge - Google Cloud Marketplace App.

It deploys the `op-scim-bridge` service with a `redis` caching server.

To work with this deployment bundle, you will need to use the `mpdev` development tool from Google. Installation and usage instructions are detailed below.

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
│   │   └── op-scim-bridge
│   │       ├── Chart.yaml
│   │       ├── README.md
│   │       ├── templates
│   │       │   ├── application.yaml
│   │       │   ├── op-scim-deployment.yaml
│   │       │   ├── op-scim-service.yaml
│   │       │   ├── op-scim-persist.yaml
│   │       │   ├── redis-service.yaml
│   │       │   ├── redis-deployment.yaml
│   │       │   └── deployer-cleanup.yaml
│   │       └── values.yaml
│   ├── deployer
│   │   └── Dockerfile
│   ├── Makefile
│   └── schema.yaml
└── README.md
```

The `op-scim-bridge` package is further broken down into five components:

- `apptest` - instructions for building the verification test image
- `chart` - the main chart (Kubernetes package) for building and running the SCIM Bridge. More information can be found in [op-scim-bridge/chart/op-scim/README.md](./op-scim-bridge/chart/op-scim/README.md)
- `deployer` - the GCP deployer which creates and runs the chart in GCP. This mechanism is maintained by GCP, and used by our package.
- `Makefile` - our makefile used to create new images. The three components (deployer, redis, op-scim-bridge) get built separately and pushed to distinct subdirectories of the op-scim-bridge GCP image.
- `schema.yaml` - defines the top level variables that will be queried in the marketplace deployer.

## Building a New Image

Using the makefile, one can create a push a new image to the Google Container Registry (GCR). To do so, one must declare environment variables:

- `REGISTRY` - the Google Cloud Registry you are building for
- `PUBLIC_TAG` - the tag/version SCIM Bridge you are building for
- `TAG` - private tag/version. Useful for testing, but this should mirror the PUBLIC_TAG when releasing.

```bash
REGISTRY="YOUR_REGISTRY" PUBLIC_TAG=2.3.0 TAG=2.3.0 make app/build
```

Alternatively, to build a testing build, you can specify a testing tag:

```bash
REGISTRY="YOUR_REGISTRY" PUBLIC_TAG=2.3.0 TAG=test-vendoring make app/build
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

You can validate your installation by running `mpdev doctor`

## Install

It is now possible to use `mpdev` to install our application on your Kubernetes cluster on GCP. This allows you to test our application outside of the marketplace.

As defined in [schema.yaml](./op-scim-bridge/schema.yaml) our application requires three arguments: `name`, `namespace`, and `accountDomain`. These parallel the values chosen in the user interface when deploying from the Marketplace.

```bash
mpdev install --deployer=gcr.io/op-scim-bridge/op-scim-bridge/deployer:latest --parameters='{"name": "mpdev", "namespace": "default", "accountDomain": "testing.1password.com" }'
```

Once this process completes, you can examine your new SCIM Bridge on GCP using kubectl or via the GCP Console in the browser.

## Verify

`mpdev` verify runs the verification test image created from the `apptest` folder. This is set at a deployer tag. Run verification like so:

```bash
mpdev verify --deployer=gcr.io/op-scim-bridge/op-scim-bridge/deployer:latest
```

The output is very long and rather hard to read, but all the components of what is happening are in there. Near the end you should see our simple `/ping` curl verification test happen.

## More

A full installation guide can be found here: [GCP MPDev Reference](https://github.com/GoogleCloudPlatform/marketplace-k8s-app-tools/blob/master/docs/mpdev-references.md)
