# Networking-Stack Helm Chart

```bash
helm dependency update

helm template networking-stack . -n networking --values values.yaml > manifest.yaml

watch -n -1 kubectl get all -n networking

helm install networking-stack . -n networking --create-namespace --values values.yaml

helm upgrade networking-stack . -n networking --values values.yaml

helm uninstall networking-stack -n networking
```
