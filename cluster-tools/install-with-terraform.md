# Installing cluster tools with Terraform

```bash
cluster_tools_installer_credentials_terraform="
  -var cluster_endpoint=$(cat cluster-endpoint.txt)
  -var cluster_ca_certificate=$(realpath cluster-ca.crt)
  -var service_account_token=$(realpath cluster-tools-installer.token)
"

terraform -chdir=cluster-tools init

TF_LOG=INFO \
terraform -chdir=cluster-tools \
apply $cluster_tools_installer_credentials_terraform \
-auto-approve \
-parallelism=1
```

## Uninstalling

```bash
cluster_tools_installer_credentials_terraform="
  -var cluster_endpoint=$(cat cluster-endpoint.txt)
  -var cluster_ca_certificate=$(realpath cluster-ca.crt)
  -var service_account_token=$(realpath cluster-tools-installer.token)
"

terraform -chdir=cluster-tools \
destroy $cluster_tools_installer_credentials_terraform \
-auto-approve
```
