
TODO install with terraform
https://piotrminkowski.com/2022/06/28/manage-kubernetes-cluster-with-terraform-and-argo-cd/
https://www.youtube.com/watch?v=TrTRy8ahIHc
https://blog.saintmalik.me/argocd-on-kubernetes-cluster/

TODO high availability for production

## Installing Argo CD with Kubectl (DEPRECATED)

```shell
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

## Installing Argo CD with Helm (DEPRECATED)

```shell
helm repo add argo https://argoproj.github.io/argo-helm

helm fetch argo/argo-cd --untar

helm install argocd ./argo-cd/ --values values.yaml --namespace argocd

# uninstall
helm uninstall argocd --namespace argocd
```

##

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
