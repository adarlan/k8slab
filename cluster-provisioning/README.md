# Local Cluster

A KinD (Kubernetes-in-Docker) cluster created with Terraform.
You could use the `kind` CLI to create the cluster,
but to make it more like a real environment, we will use Terraform.

## Configuring Terraform

```bash
tfenv install 1.7.3
tfenv use 1.7.3

TF_LOG="INFO"
```

## Creating the cluster

```bash
terraform init
terraform apply
```

## Setting the maximum number of file system notification subscribers

Applications can use the `fs.inotify` Linux kernel subsystem to register for notifications when specific files or directories are modified, accessed, or deleted.
Let's increase the value of the `fs.inotify.max_user_instances` kernel parameter to prevent some containers in the monitoring stack from crashing due to "too many open files" while watching for changes in the log files.
Since both host and containers share the same kernel, configuring it on the host also applies to the Docker containers used as cluster nodes, and also to the pod's containers running inside those nodes.
This value is reset when the system restarts.

```bash
if [ $(sysctl -n fs.inotify.max_user_instances) -lt 1024 ]; then
    sudo sysctl -w fs.inotify.max_user_instances=1024
fi
```

## Setting kubeconfig cluster

```bash
docker cp k8slab-control-plane:/etc/kubernetes/pki/ca.crt ca.crt
# terraform output -raw ca_certificate > ca.crt

kubectl config set-cluster k8slab --server=$(terraform output -raw endpoint) --certificate-authority=ca.crt --embed-certs=true
```

## Setting kubeconfig root user and context

```bash
terraform output -raw root_user_key > root.key
terraform output -raw root_user_certificate > root.crt

kubectl config set-credentials k8slab-root --client-key=root.key --client-certificate=root.crt --embed-certs=true
kubectl config set-context k8slab-root --cluster=k8slab --user=k8slab-root

kubectl config use-context k8slab-root
```

## Cluster info and nodes

```bash
kubectl cluster-info
kubectl get nodes
```

<!-- FUNCTION destroy -->
## Destroying the cluster

```bash
terraform destroy
```

<!-- FUNCTION clean -->
## Clean

Stop and remove cluster nodes, remove Terraform files, remove keys and certificates.

```bash
docker ps -a --format "{{.Names}}" | grep "^k8slab-" | while read -r container_name; do
    docker stop "$container_name" >/dev/null 2>&1
    docker rm "$container_name" >/dev/null 2>&1
done

git clean -Xfd
```
