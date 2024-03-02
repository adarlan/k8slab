# ArgoCD Applications

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
