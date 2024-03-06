# Cluster Toolkit

<!-- FUNCTION build -->
## Update dependencies

```bash
for chartPath in */; do
    if [ -d "$chartPath" ]; then
        cd $chartPath
        helm dependency update
        cd -
    fi
done
```

Render templates (won't be used)

```bash
for chartPath in */; do
    if [ -d "$chartPath" ]; then

        chartName=$(basename $chartPath)
        releaseName=$chartName
        namespace=$releaseName
        valuesFile=$chartName/values.yaml

        (
            set -ex
            helm template $releaseName $chartPath -n $namespace --values $valuesFile
        )
    fi
done
```

<!-- FUNCTION install -->
## Install

```bash
kubectl config use-context k8slab-root
```

### Installing Networking-Stack

```bash
cd networking-stack

if helm list --short -n networking | grep -q '^networking-stack$'; then
    helm upgrade networking-stack -n networking --values values.yaml .
else
    helm install networking-stack -n networking --create-namespace --values values.yaml .
fi
```

### Installing ArgoCD-Stack

```bash
cd argocd-stack

if helm list --short -n argocd | grep -q '^argocd-stack$'; then
    helm upgrade argocd-stack -n argocd --values values.yaml .
else
    helm install argocd-stack -n argocd --create-namespace --values values.yaml .
fi
```

### Installing Monitoring-Stack

```bash
cd monitoring-stack

if helm list --short -n monitoring | grep -q '^monitoring-stack$'; then
    helm upgrade monitoring-stack -n monitoring --values values.yaml .
else
    helm install monitoring-stack -n monitoring --create-namespace --values values.yaml .
fi
```

### Installing Security-Stack

```bash
cd security-stack

if helm list --short -n security | grep -q '^security-stack$'; then
    helm upgrade security-stack -n security --values values.yaml .
else
    helm install security-stack -n security --create-namespace --values values.yaml .
fi
```

<!-- FUNCTION watchpods -->
## Watch pods

```bash
watch -n 1 kubectl get pod -n argocd
watch -n 1 kubectl get pod -n networking
watch -n 1 kubectl get pod -n monitoring
watch -n 1 kubectl get pod -n security
```

<!-- FUNCTION postinstall -->
## Post-install

### ArgoCD

[http://argocd.localhost](http://argocd.localhost/login?return_url=http%3A%2F%2Fargocd.localhost%2Fapplications)

```bash
# get initial admin password
echo $(kubectl get secret -n argocd argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 --decode)

# argocd login (using the --grpc-web flag because ingressGrpc is not configured)
argocd login --grpc-web --insecure argocd.localhost --username admin --password $(kubectl get secret -n argocd argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 --decode)
```

### Grafana

```bash
echo $(kubectl get secret -n monitoring monitoring-stack-grafana -o jsonpath="{.data.admin-password}" | base64 --decode)

# using port-forward while we don't have ingress configuration
kubectl port-forward -n monitoring service/monitoring-stack-grafana 8080:80
```

Open Grafana: http://localhost:8080

Add data source >> Loki

- Connection URL: http://loki-gateway:80
- HTTP headers: X-Scope-OrgID=foobar
- Save & test

Add data source >> Prometheus

- ???

<!-- FUNCTION uninstall -->
## Uninstall

```bash
kubectl config use-context k8slab-root

helm uninstall argocd-stack -n argocd
helm uninstall networking-stack -n networking
helm uninstall monitoring-stack -n monitoring
helm uninstall security-stack -n security
```

## Ref

Loki Source Code
https://github.com/grafana/loki

Loki Helm Chart
https://github.com/grafana/loki/tree/main/production/helm/loki

Loki Docs - Install Grafana Loki with Helm
https://grafana.com/docs/loki/latest/setup/install/helm/

Loki Docs - Install the monolithic Helm chart
https://grafana.com/docs/loki/latest/setup/install/helm/install-monolithic/

Loki Docs - Install the simple scalable Helm chart
https://grafana.com/docs/loki/latest/setup/install/helm/install-scalable/

HackerNoon - Grafana Loki: Architecture Summary and Running in Kubernetes
https://hackernoon.com/grafana-loki-architecture-summary-and-running-in-kubernetes

Promtail Helm Chart
https://github.com/grafana/helm-charts/tree/main/charts/promtail

## TODO

When installing the monitoring stack via Argo CD:
RepeatedResourceWarning - After sync, Argo CD display 3 warnings

Add Grafana data sources in the values.yaml

Ingress configuration for Grafana and Prometheus (Loki too?)