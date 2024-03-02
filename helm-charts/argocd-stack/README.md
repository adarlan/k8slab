# ArgoCD-Stack Helm Chart

This chart includes:

- Argo CD Server
- Ingress (Nginx) resource for Argo CD Server
- Argo CD Image Updater

After installation, access in your browser:

- [http://argocd.localhost](http://argocd.localhost/login?return_url=http%3A%2F%2Fargocd.localhost%2Fapplications)

## Commands

```bash
# update chart dependencies
helm dependency update

# render the manifest file (just for checking, as it will not be used)
helm template argocd-stack . -n argocd --values values.yaml > manifest.yaml
```

```bash
# watch the resources being created, updated, and deleted
watch -n -1 kubectl get all -n argocd

# install
helm install argocd-stack . -n argocd --create-namespace --values values.yaml

# upgrade
helm upgrade argocd-stack . -n argocd --values values.yaml

# uninstall
helm uninstall argocd-stack -n argocd
```

```bash
# get initial admin password
echo $(kubectl get secret -n argocd argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 --decode)

# argocd login (using the --grpc-web flag because ingressGrpc is not configured)
argocd login --grpc-web --insecure argocd.localhost --username admin --password $(kubectl get secret -n argocd argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 --decode)
```

## Ref

Argo CD Helm Chart
https://github.com/argoproj/argo-helm/tree/main/charts/argo-cd

Multiple ingress resources for gRPC protocol support
https://github.com/argoproj/argo-helm/tree/main/charts/argo-cd#multiple-ingress-resources-for-grpc-protocol-support
