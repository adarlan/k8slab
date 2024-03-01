# Monitoring Stack Helm Chart

## Handy Commands

```bash
helm dependency update

watch -n -1 kubectl get all -n monitoring

helm install monitoring-stack . -n monitoring --debug --values values.yaml

helm upgrade monitoring-stack . -n monitoring --debug --values values.yaml

kubectl port-forward -n monitoring service/monitoring-stack-loki 3100
curl http://localhost:3100/ready

helm uninstall monitoring-stack . -n monitoring --debug

helm template monitoring-stack . -n monitoring --values values.yaml > manifest.yaml
```

## Ref

Loki Docs - Loki HTTP API
https://grafana.com/docs/loki/latest/reference/api/

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
