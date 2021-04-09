# Updating these tools

Due the directory structure of upstream, you must update these tools manually.

Original repo is here: https://github.com/GoogleCloudPlatform/marketplace-k8s-app-tools

Check the repository out.

```bash
git clone https://github.com/GoogleCloudPlatform/marketplace-k8s-app-example
```

Then, copy over the files that have changed:

```bash
cd marketplace-k8s-app-example/
cp app_v2.Makefile common.Makefile gcloud.Makefile var.Makefile /path/to/op-scim-gcp-marketplace/tools
```

Given that GCPs tools change so rapidly, you may find that filenames and structure have changed since the last upgrade, resulting in the `Makefile` not working as expected. There’s no way around this other than trial and error.
