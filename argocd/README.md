# ArgoCD

<!-- FUNCTION install -->
## Install or Upgrade

```bash
kubectl config use-context k8slab-root

if helm list --short -n argocd | grep -q '^argocd$'; then
    helm upgrade argocd -n argocd --values installation/values.yaml installation
else
    helm install argocd -n argocd --create-namespace --values installation/values.yaml installation
fi
```

<!-- watch -n 1 kubectl get pod -n argocd -->

## Setting kubeconfig for application deployer

```bash
kubectl config use-context k8slab-root
kubectl config set-credentials k8slab-deployer --token=$(kubectl get secret argocd-application-deployer -n argocd -o jsonpath='{.data.token}' | base64 --decode)
kubectl config set-context k8slab-deployer --cluster=k8slab --user=k8slab-deployer --namespace=argocd
```

<!-- FUNCTION toolkit -->
## Deploy Toolkit Applications

```bash
kubectl config use-context k8slab-deployer
KUBECTL_APPLYSET=true kubectl apply -n argocd --prune --applyset=toolkit-applications -f toolkit-applications/

# KUBECTL_APPLYSET=true kubectl delete -n argocd --applyset=toolkit-applications -f toolkit-applications/
```

<!-- FUNCTION login -->
## Login

__Note__: It only works after ingress controller is ready.

[http://argocd.localhost](http://argocd.localhost/login?return_url=http%3A%2F%2Fargocd.localhost%2Fapplications)

```bash
# get initial admin password
echo $(kubectl get secret -n argocd argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 --decode)

# argocd login (using the --grpc-web flag because ingressGrpc is not configured)
argocd login --grpc-web --insecure argocd.localhost --username admin --password $(kubectl get secret -n argocd argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 --decode)
```

<!-- FUNCTION deploy -->
## Deploy Applications

```bash
# deploy applications
KUBECTL_APPLYSET=true kubectl apply -n argocd --prune --applyset=argocd-applications -f applications/

# deploy application-sets
KUBECTL_APPLYSET=true kubectl apply -n argocd --prune --applyset=argocd-application-sets -f application-sets/

# deploy application-templates
helm list --short -n argocd | grep -q '^argocd-apps$' && helm upgrade argocd-apps -n argocd application-templates/ || helm install argocd-apps -n argocd --create-namespace application-templates/

# undeploy applications
KUBECTL_APPLYSET=true kubectl delete -n argocd --applyset=argocd-applications -f applications/

# undeploy application-sets
KUBECTL_APPLYSET=true kubectl delete -n argocd --applyset=argocd-application-sets -f application-sets/

# undeploy application-templates
helm uninstall argocd-apps -n argocd
```

<!-- FUNCTION uninstall -->
## Uninstall

```bash
kubectl config use-context k8slab-root
helm uninstall argocd -n argocd
```
