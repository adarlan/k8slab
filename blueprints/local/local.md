
Creating the cluster

```shell
terraform apply -auto-approve
```

Exporting the kubeconfig file

```shell
terraform output kubeconfig > kubeconfig
sed -i '1s/^<<EOT$//' kubeconfig
sed -i '${/^EOT$/d;}' kubeconfig 
```

Interacting with the cluster

```shell
kubectl --kubeconfig kubeconfig cluster-info
```
