# Updating the Marketplace tools

Due the directory structure of upstream, you must update these tools manually.

Original repo is here: https://github.com/GoogleCloudPlatform/marketplace-k8s-app-tools

To update the tools follow these steps:

1. Check the repository out.

    ```bash
    git clone https://github.com/GoogleCloudPlatform/marketplace-k8s-app-example
    ```

2. Then, copy over the files that have changed:

    ```bash
    cd marketplace-k8s-app-example/
    cp app.Makefile common.Makefile crd.Makefile gcloud.Makefile var.Makefile /path/to/op-scim-gcp-marketplace/tools
    ```

3. Lastly, ensure that the `MARKETPLACE_TOOLS_TAG` is updated and set to the latest available [tag](https://github.com/GoogleCloudPlatform/marketplace-k8s-app-tools/tags).

Note that GCPs tools change frequently. You may find that filenames and structure have changed since the last upgrade, resulting in the `op-scim-bridge/Makefile` not working as expected. Unfortunately there’s no easy way around this other than trial and error.
