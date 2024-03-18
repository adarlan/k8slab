
We'll use Terraform to install Argo CD and then use Argo CD to install the other tools.

### Installing Argo CD with Terraform (~5 minutes)

We'll use the Terraform `-target` option to limit the operation to only the `helm_release.argocd_stack` resource and its dependencies.
As argocd-stack depends on networking-stack, the networking-stack will also be installed.

As the `-target` option is for exceptional use only,
Terraform will warn "Resource targeting is in effect" and "Applied changes may be incomplete",
but for the purposes of this simulation you can ignore these messages.

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
-parallelism=1 \
-target=helm_release.argocd_stack
```

```bash
# Uninstalling cluster tools that were installed with argocd
kubectl --server=$(cat cluster-endpoint.txt) --token=$(cat argocd-application-deployer.token) \
delete \
-n argocd \
-f argocd/toolkit-applications/ \
-l selection=toolkit-applications

# Uninstalling argocd stack and its dependencies
terraform -chdir=cluster-tools \
destroy \
-var cluster_ca_certificate=../cluster-ca.crt \
-var service_account_token=../cluster-tools-installer.token \
-var cluster_endpoint=$(cat cluster-endpoint.txt) \
-auto-approve
```

### Installing cluster tools with Argo CD

```bash
argocd_application_deployer_credentials_helm="
  --kube-apiserver=$(cat cluster-endpoint.txt)
  --kube-ca-file=$(realpath cluster-ca.crt)
  --kube-token=$(cat argocd-application-deployer.token)
"

release=cluster-tools-argocd-apps
chart=./cluster-tools/.argocd-apps
values=./cluster-tools/.argocd-apps/values.yaml
namespace=argocd

list=$(helm $argocd_application_deployer_credentials_helm list --short -n $namespace)
echo "$list" | grep -q "^$release$" \
&& helm $argocd_application_deployer_credentials_helm upgrade $release --values $values $chart -n $namespace \
|| helm $argocd_application_deployer_credentials_helm install $release --values $values $chart -n $namespace
```

### Waiting security stack synchronization

```bash
argocd app wait security-stack
```

### Waiting monitoring stack synchronization

The monitoring stack usually takes a long time to synchronize,
and its health state usually transitions to 'Degraded' at some point during the synchronization,
causing the `argocd app wait` command to fail, despite the synchronization process continuing.
Because of this we will try to wait two more times.

```bash
retries=0
until argocd app wait monitoring-stack; do
  ((++retries)); if [ $retries -ge 3 ]; then exit 1; fi
done
```
