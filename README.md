# K8sLab

## Running locally

### Create local environment

```shell
cd kind-environment
./up.sh
```

### Open argo-cd

Open in your browser:
https://127.0.0.1:8080

Username:
`admin`

Retrieve the password by running:

```shell
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath='{.data.password}' | base64 --decode
```

### Open applications

hello-world: https://127.0.0.1:8081

### Destroy local environment

```shell
cd kind-environment
./up.sh
```
