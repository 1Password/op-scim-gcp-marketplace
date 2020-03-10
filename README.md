# 1Password SCIM Bridge (op-scim) on GCP

op-scim-gcp-marketplace is the bundling of the 1Password SCIM Bridge into a format suitable for the GCP Marketplace. The application can be found here:

Generally this package describes a chart which wraps the op-scim docker image and deploys it as a service on a GCP Kubernetes Cluster alongside a redis service.

To work with this deployment bundle, a developer requires use of the `mpdev` development tool from GCP. Installation and usage instructions are detailed below.

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
│   │   └── op-scim
│   │       ├── Chart.yaml
│   │       ├── README.md
│   │       ├── templates
│   │       │   ├── application.yaml
│   │       │   ├── op-scim.yaml
│   │       │   └── redis.yaml
│   │       └── values.yaml
│   ├── deployer
│   │   └── Dockerfile
│   ├── Makefile
│   └── schema.yaml
├── README.md
└── vendor
```
The top level of this package has three items: this README, vendored marketplace-tools, and the op-scim-bridge GCP package.

The op-scim-bridge package is further broken down into five components:
- apptest -> Instructions for building the verification test image
- chart -> The main chart (Kubernetes package) for building and running the SCIM Bridge. More information can be found in [op-scim-bridge/chart/op-scim/README.md](./op-scim-bridge/chart/op-scim/README.md)
- deployer -> The GCP deployer which creates and runs the chart in GCP. This mechanism is maintained by GCP, and used by our package.
- Makefile -> Our makefile used to create new images. The three components (deployer, redis, op-scim-bridge) get built separately and pushed to distinct subdirectories of the op-scim-bridge GCP image.
- schema.yaml -> Defines the top level variables that will be queried in the marketplace deployer.

## Building a New Image

Using the makefile, one can create a push a new image to the Google Container Registry (GCR). To do so, one must declare environment variables:

- REGISTRY - The google cloud registry we are building for
- PUBLIC_TAG of the SCIM Bridge we are building off of.
- TAG to put on GCP. When releasing, these should mirror the PUBLIC_TAG

```
PUBLIC_TAG=1.3.0-2 TAG=1.3.0-2 make app/build
```

Alternatively, to build a testing build, one may specify a testing tag

```
PUBLIC_TAG=1.3.0-2 TAG=test-vendoring make app/build
```

## MPDev

`mpdev` is a command line tool from the marketplace tool which allows one to build, install, and verify a GCP Marketplace application.

A pre-requisite to using mpdev is an existing `kubectl` installation with access to your GCP Kubernetes cluster.

Any reference to `--deployer=gcr.op/op-scim-bridge/op-scim-bridge/deployer:TAG` is referencing the constructed docker image. If not present locally, this will be pulled from the Google Container Registry.

Tags are updated regularly and may vary. The `latest` tag is not always updated, so be sure to check dates when pulling. For illustrative purposes, these examples will use the `latest` tag.

### Tool Installation

The installation process concludes with a PATH-able binary somewhere on your machine through running a docker image locally. Feel free to customise to your setup, but this was what worked for me:

```
BIN_FILE="/usr/local/bin/mpdev"

docker run gcr.io/cloud-marketplace-tools/k8s/dev cat /scripts/dev > "$BIN_FILE"
```
Two notes:
    - `/usr/local/bin/*` was already PATH-able for me
    - The use of the `BIN_FILE` seemed necessary as otherwise the docker run did not output correctly


You can validate your installation by running `mpdev doctor`

### mpdev install

It is now possible to use mpdev to install our application on your Kubernetes cluster on GCP. This allows you to test our application outside of the marketplace.

As defined in [schema.yaml](./op-scim-bridge/schema.yaml) our application requires three arguments: `APP_INSTANCE_NAME`, `NAMESPACE`, and `OP_ACCOUNT_DOMAIN`. These parallel the values chosen in the user interface when deploying from the marketplace. This example uses `opscim.b5test.com`, but please replace that with your testing account, as otherwise your bridge will not allow the authentication.

```
mpdev install --deployer=gcr.io/op-scim-bridge/op-scim-bridge/deployer:latest --parameters='{"APP_INSTANCE_NAME": "mpdev", "NAMESPACE": "default", "OP_ACCOUNT_DOMAIN": "opscim.b5test.com"}'
```
Once this process completes, you can examine your new SCIM Bridge on GCP using kubectl or via the GCP Console in the browser.

### mpdev verify


mpdev verify runs the verification test image created from the `apptest` folder. This is set at a deployer tag. Run verification like so:

```
mpdev verify --deployer=gcr.io/op-scim-bridge/op-scim-bridge/deployer:latest
```

The output is very long and rather hard to read, but all the components of what is happening are in there. Near the end you should see our simple `/ping` curl verification test happen. 

### More

A full installation guide can be found here: [GCP MPDev Reference](https://github.com/GoogleCloudPlatform/marketplace-k8s-app-tools/blob/master/docs/mpdev-references.md)


## Git Submodules

This repository uses [GoogleCloudPlatform/marketplace-k8s-app-tools](https://github.com/GoogleCloudPlatform/marketplace-k8s-app-tools.git) submodule.
Please run following commands to receive newest version of used modules.

### Updating git submodules

You can use make to make sure submodules
are populated with proper code.

```shell
make submodule/init # or make submodule/init-force
```

Alternatively, you can invoke these commands directly in shell, without `make`.

```shell
git submodule init
git submodule sync --recursive
git submodule update --recursive --init
```

## Further information

