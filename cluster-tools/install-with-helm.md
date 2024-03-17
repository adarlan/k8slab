# Installing cluster tools with Helm

```bash
cluster_tools_installer_credentials_helm="
  --kube-apiserver=$(cat cluster-endpoint.txt)
  --kube-ca-file=$(realpath cluster-ca.crt)
  --kube-token=$(cat cluster-tools-installer.token)
"

cluster_tools_installer_credentials_kubectl="
  --server=$(cat cluster-endpoint.txt)
  --certificate-authority=$(realpath cluster-ca.crt)
  --token=$(cat cluster-tools-installer.token)
"

install-or-upgrade-cluster-tool() {
  helm repo add $repo_name $repo_url

  helm_list=$(helm $cluster_tools_installer_credentials_helm list --short -n $namespace)
  echo "$helm_list" | grep -q "^$release_name$" && install_or_upgrade=upgrade || install_or_upgrade=install

  helm $cluster_tools_installer_credentials_helm \
  $install_or_upgrade \
  $release_name \
  $repo_name/$chart_name \
  --version $chart_version \
  --values $values_file \
  --namespace $namespace \
  --create-namespace

  kubectl $cluster_tools_installer_credentials_kubectl \
  wait pods --namespace=$namespace --all=true --for=condition=Ready --timeout=1200s
}

# ingress-nginx
(
  release_name=ingress-nginx \
  repo_name=ingress-nginx \
  repo_url=https://kubernetes.github.io/ingress-nginx \
  chart_name=ingress-nginx \
  chart_version=4.10.0 \
  values_file=cluster-tools/values/ingress-nginx.values.yaml \
  namespace=ingress \
  install-or-upgrade-cluster-tool
)

# loki
(
  release_name=loki \
  repo_name=grafana \
  repo_url=https://grafana.github.io/helm-charts \
  chart_name=loki \
  chart_version=5.43.3 \
  values_file=cluster-tools/values/loki.values.yaml \
  namespace=monitoring \
  install-or-upgrade-cluster-tool
)

# promtail
(
  release_name=promtail \
  repo_name=grafana \
  repo_url=https://grafana.github.io/helm-charts \
  chart_name=promtail \
  chart_version=6.15.5 \
  values_file=cluster-tools/values/promtail.values.yaml \
  namespace=monitoring \
  install-or-upgrade-cluster-tool
)

# kube-prometheus-stack
(
  release_name=kube-prometheus-stack \
  repo_name=prometheus-community \
  repo_url=https://prometheus-community.github.io/helm-charts \
  chart_name=kube-prometheus-stack \
  chart_version=56.6.2 \
  values_file=cluster-tools/values/kube-prometheus-stack.values.yaml \
  namespace=monitoring \
  install-or-upgrade-cluster-tool
)

# trivy-operator
(
  release_name=trivy-operator \
  repo_name=aquasecurity \
  repo_url=https://aquasecurity.github.io/helm-charts \
  chart_name=trivy-operator \
  chart_version=0.20.6 \
  values_file=cluster-tools/values/trivy-operator.values.yaml \
  namespace=trivy \
  install-or-upgrade-cluster-tool
)

# argo-cd
(
  release_name=argo-cd \
  repo_name=argo \
  repo_url=https://argoproj.github.io/argo-helm \
  chart_name=argo-cd \
  chart_version=6.4.1 \
  values_file=cluster-tools/values/argo-cd.values.yaml \
  namespace=argocd \
  install-or-upgrade-cluster-tool
)
```

## Uninstalling

```bash
cluster_tools_installer_credentials_helm="
  --kube-apiserver=$(cat cluster-endpoint.txt)
  --kube-ca-file=$(realpath cluster-ca.crt)
  --kube-token=$(cat cluster-tools-installer.token)
"

cluster_tools_installer_credentials_kubectl="
  --server=$(cat cluster-endpoint.txt)
  --certificate-authority=$(realpath cluster-ca.crt)
  --token=$(cat cluster-tools-installer.token)
"

uninstall-cluster-tool() {
  helm $cluster_tools_installer_credentials_helm \
  uninstall \
  $release_name \
  --namespace $namespace
}

release_name=argo-cd \
namespace=argocd \
uninstall-cluster-tool

release_name=trivy-operator \
namespace=trivy \
uninstall-cluster-tool

release_name=kube-prometheus-stack \
namespace=monitoring \
uninstall-cluster-tool

release_name=promtail \
namespace=monitoring \
uninstall-cluster-tool

release_name=loki \
namespace=monitoring \
uninstall-cluster-tool

release_name=ingress-nginx \
namespace=ingress \
uninstall-cluster-tool

wait-pods-delete() {
  kubectl $cluster_tools_installer_credentials_kubectl \
  wait pods --namespace=$namespace --all=true --for=delete --timeout=1200s
}

namespace=argocd wait-pods-delete
namespace=trivy wait-pods-delete
namespace=monitoring wait-pods-delete
namespace=ingress wait-pods-delete
```
