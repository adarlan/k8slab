
TODO install with terraform
https://blog.saintmalik.me/argocd-on-kubernetes-cluster/

Installing Argo CD

```shell
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

Exposing the Argo CD API server

```shell
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

Adding the cluster to Argo CD

```shell
ARGOCD_PASSWORD=$(kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath='{.data.password}' | base64 --decode)
CONTEXT_CLUSTER=$(kubectl config get-contexts -o name)
argocd login --insecure localhost:8080 --username admin --password $ARGOCD_PASSWORD
argocd cluster add $CONTEXT_CLUSTER -y --in-cluster
```

##

Open in browser:
https://127.0.0.1:8080/
