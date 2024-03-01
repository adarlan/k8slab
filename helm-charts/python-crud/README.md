# Python CRUD Helm Chart

```bash
helm dependency update

watch -n -1 kubectl get all -n python-crud

helm install python-crud . -n python-crud --create-namespace --values values.yaml

helm upgrade python-crud . -n python-crud --values values.yaml

helm uninstall python-crud . -n python-crud --debug

helm template python-crud . -n python-crud --values values.yaml > manifest.yaml
```
