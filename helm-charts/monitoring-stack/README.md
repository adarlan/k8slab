# Monitoring-Stack Helm Chart

## Commands

```bash
helm dependency update

helm template monitoring-stack . -n monitoring --values values.yaml > manifest.yaml
```

```bash
watch -n -1 kubectl get all -n monitoring

helm install monitoring-stack . -n monitoring --create-namespace --values values.yaml

helm upgrade monitoring-stack . -n monitoring --values values.yaml

helm uninstall monitoring-stack . -n monitoring --debug
```

```bash
echo $(kubectl get secret -n monitoring monitoring-stack-grafana -o jsonpath="{.data.admin-password}" | base64 --decode)

# using port-forward while we don't have ingress configuration
kubectl port-forward -n monitoring service/monitoring-stack-grafana 8080:80
```

## Add Grafana data sources

Open Grafana: http://localhost:8080

Add data source >> Loki

- Connection URL: http://loki-gateway:80
- HTTP headers: X-Scope-OrgID=foobar
- Save & test

Add data source >> Prometheus

- ???

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

RepeatedResourceWarning - After sync, Argo CD display 3 warnings

Add Grafana data sources in the values.yaml

Ingress configuration for Grafana and Prometheus (Loki too?)
