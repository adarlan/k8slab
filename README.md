# K8sLab

## Running locally

### Create local environment

```shell
./up.sh
```

### Open Argo CD server

Open in your browser:
https://127.0.0.1:8080

Username:
`admin`

Retrieve the password by running:

```shell
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath='{.data.password}' | base64 --decode
```

### Open applications in your browser

hello-world: http://127.0.0.1:8081

### Destroy local environment

```shell
./down.sh
```
