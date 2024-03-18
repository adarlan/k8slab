# Creating local cluster with Terraform

```bash
terraform -chdir=local-cluster init

TF_LOG="INFO" \
terraform -chdir=local-cluster apply -auto-approve
```

## Destroying

```bash
terraform -chdir=local-cluster destroy -auto-approve
```
