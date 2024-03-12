# K8sLab

A collection of components designed to simplify the provisioning and management of Kubernetes clusters across different environments, including major cloud providers and local setups. It creates a ready-to-use Kubernetes platform bundled with popular open-source tools and example applications.

## Features

- Automated provisioning of [Kubernetes](https://kubernetes.io/) clusters, whether in the cloud with [Amazon EKS](https://aws.amazon.com/eks/) or locally with [KinD](https://kind.sigs.k8s.io/).
- Infrastructure provisioning with [Terraform](https://www.terraform.io/).
- Package management with [Helm](https://helm.sh/) for deploying Kubernetes rousources.
- [Ingress NGINX Controller](https://kubernetes.github.io/ingress-nginx/) for managing incoming traffic to the cluster.
- Continuous delivery using [Argo CD](https://argoproj.github.io/cd/) for GitOps workflows.
- Monitoring and alerting with [Prometheus](https://prometheus.io/) and [Grafana](https://grafana.com/grafana/).
- [Trivy Operator](https://aquasecurity.github.io/trivy-operator) to continuously scan the Kubernetes cluster for security issues.
- [Karpenter](https://karpenter.sh/) for automatic node scaling based on resource usage.
- Continuous integration pipelines using [GitHub Actions](https://github.com/features/actions).
- [Docker Engine](https://docs.docker.com/engine/) for containerization of applications.

## Configuring Terraform

```bash
tfenv install 1.7.3
tfenv use 1.7.3
```

## Setting the maximum number of file system notification subscribers

Applications can use the `fs.inotify` Linux kernel subsystem to register for notifications when specific files or directories are modified, accessed, or deleted.

Let's increase the value of the `fs.inotify.max_user_instances` parameter to prevent some containers in the monitoring stack from crashing due to "too many open files" while watching for changes in the log files.

Since both host and containers share the same kernel, configuring it on the host also applies to the Docker containers that KinD uses as cluster nodes, and also to the pod's containers running inside those nodes.

This value is reset when the system restarts.

```bash
if [ $(sysctl -n fs.inotify.max_user_instances) -lt 1024 ]; then
  sudo sysctl -w fs.inotify.max_user_instances=1024
fi
```

## Provisioning local cluster (~2 minutes)

Provisioning a KinD (Kubernetes-in-Docker) cluster in the local environment using Terraform.
You could use the `kind` CLI to create the cluster, but to make it more like a real environment, we will use Terraform.

```bash
terraform -chdir=local-cluster init

TF_LOG="INFO" \
terraform -chdir=local-cluster apply -auto-approve
```

## Retrieving cluster credentials

The directory `/etc/kubernetes/pki/` of a control-plane node typically contains the Public Key Infrastructure (PKI) assets used by the Kubernetes control-plane components for secure communication and authentication within the cluster.

```bash
# Retrieving cluster's Certificate Authority (CA) key and certificate
docker cp k8slab-control-plane:/etc/kubernetes/pki/ca.key cluster-ca.key
docker cp k8slab-control-plane:/etc/kubernetes/pki/ca.crt cluster-ca.crt

# Retrieving cluster's endpoint
terraform -chdir=local-cluster output -raw endpoint > cluster-endpoint.txt

# Retrieving root user's key and certificate
terraform -chdir=local-cluster output -raw root_user_key > root.key
terraform -chdir=local-cluster output -raw root_user_certificate > root.crt
```

## Setting cluster entry in kubeconfig

When you create a KinD cluster, a kubeconfig file is automatically configured to access the cluster, but we won't use it. Instead, we will set up the kubeconfig from scratch.

```bash
# Setting cluster entry in kubeconfig
kubectl config set-cluster k8slab --server=$(cat cluster-endpoint.txt) --certificate-authority=cluster-ca.crt --embed-certs=true
```

## Setting root user in kubeconfig

```bash
# Setting user entry in kubeconfig
kubectl config set-credentials k8slab-root --client-key=root.key --client-certificate=root.crt --embed-certs=true

# Setting context entry in kubeconfig
kubectl config set-context k8slab-root --cluster=k8slab --user=k8slab-root

# Switching to root user
kubectl config use-context k8slab-root
```

## Granting user credentials

Let's create two dummy users:

- John Dev, who will be given the 'developer' role.
- Jane Ops, who will be given the 'administrator' cluster-role.

### Generating private keys and Certificate Signing Request (CSR) files

```bash
# Generating private keys
openssl genrsa -out johndev.key 2048
openssl genrsa -out janeops.key 2048

# Generating CSR files
openssl req -new -key johndev.key -out johndev.csr -subj "/CN=John Dev"
openssl req -new -key janeops.key -out janeops.csr -subj "/CN=Jane Ops"
```

### Signing certificates

```bash
# Signing certificates
openssl x509 -req -in johndev.csr -CA cluster-ca.crt -CAkey cluster-ca.key -CAcreateserial -out johndev.crt -days 1
openssl x509 -req -in janeops.csr -CA cluster-ca.crt -CAkey cluster-ca.key -CAcreateserial -out janeops.crt -days 1
```

### Setting user credentials in kubeconfig

```bash
# Setting user entries in kubeconfig
kubectl config set-credentials k8slab-johndev --client-key=johndev.key --client-certificate=johndev.crt --embed-certs=true
kubectl config set-credentials k8slab-janeops --client-key=janeops.key --client-certificate=janeops.crt --embed-certs=true

# Setting context entries in kubeconfig
kubectl config set-context k8slab-johndev --cluster=k8slab --user=k8slab-johndev
kubectl config set-context k8slab-janeops --cluster=k8slab --user=k8slab-janeops
```

## Applying Role-Based Access Control (RBAC) resources

This will create the 'developer' role and the 'administrator' cluster-role,
as well as bind them to 'John Dev' and 'Jane Ops' users, respectively.

This will also create the 'cluster-tools-installer' and 'argocd-application-deployer' service accounts.

```bash
# Applying RBAC resources
kubectl apply -f rbac/ \
--prune -l selection=rbac \
--prune-allowlist=rbac.authorization.k8s.io/v1/ClusterRole \
--prune-allowlist=rbac.authorization.k8s.io/v1/ClusterRoleBinding \
--prune-allowlist=rbac.authorization.k8s.io/v1/Role \
--prune-allowlist=rbac.authorization.k8s.io/v1/RoleBinding
```

## Retrieving service account tokens

In a real environment, these tokens would typically be incorporated into the CI/CD secrets.
However, for the purposes of this simulation, let's store them in files instead.

```bash
# Retrieving cluster-tools-installer service account token
kubectl get secret cluster-tools-installer -o jsonpath='{.data.token}' | base64 --decode > cluster-tools-installer.token

# Retrieving argocd-application-deployer service account token
kubectl get secret argocd-application-deployer -n argocd -o jsonpath='{.data.token}' | base64 --decode > argocd-application-deployer.token
```

## Installing cluster tools

Cluster-tools is a collection of Helm charts that extend the functionality of the Kubernetes cluster,
improving deployments, security, networking, monitoring, etc.,
by adding tools such as Argo CD, Prometheus, Grafana, Trivy Operator, NGINX Ingress Controller, and more.

These tools can be installed in 3 ways:

- Using Helm
- Using Terraform
- Using Argo CD (in this case, the argocd-stack must be installed first with Helm or Terraform)

We'll use Terraform to install Argo CD and then use Argo CD to install the other tools.

### Installing Argo CD with Terraform (~5 minutes)

We'll use the Terraform `-target` option to limit the operation to only the `helm_release.argocd_stack` resource and its dependencies.
As argocd-stack depends on networking-stack, the networking-stack will also be installed.

As the `-target` option is for exceptional use only,
Terraform will warn "Resource targeting is in effect" and "Applied changes may be incomplete",
but for the purposes of this simulation you can ignore these messages.

```bash
terraform -chdir=cluster-tools init

TF_LOG=INFO \
terraform -chdir=cluster-tools apply \
-var cluster_ca_certificate=../cluster-ca.crt \
-var service_account_token=../cluster-tools-installer.token \
-var cluster_endpoint=$(cat cluster-endpoint.txt) \
-auto-approve -parallelism=1 \
-target=helm_release.argocd_stack
```

### Installing cluster-tools with Argo CD

```bash
kubectl --token=$(cat argocd-application-deployer.token) --server=$(cat cluster-endpoint.txt) \
apply -n argocd -f argocd/toolkit-applications/ \
--prune -l selection=toolkit-applications \
--prune-allowlist=argoproj.io/v1alpha1/Application \
--prune-allowlist=argoproj.io/v1alpha1/ApplicationSet
```

### Argo CD login

```bash
kubectl config use-context k8slab-janeops
argocdPassword=$(kubectl get secret -n argocd argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 --decode)

# argocd login (using the --grpc-web flag because ingressGrpc is not yet configured)
argocd login --grpc-web --insecure argocd.localhost --username admin --password $argocdPassword
```

### Waiting cluster-tools synchronization (~20 minutes)

The monitoring-stack usually takes a long time to synchronize,
and its health state usually transitions to 'Degraded' at some point during the synchronization,
causing the `argocd app wait` command to fail, despite the synchronization process continuing.
Because of this we will retry two more times.

```bash
retries=0
until argocd app wait -l selection=toolkit-applications; do
  ((++retries)); if [ $retries -ge 3 ]; then break; fi
done
```

<!-- FUNCTION manual -->

## Argo CD UI

Get initial admin password:

```bash
kubectl config use-context k8slab-janeops
echo $(kubectl get secret -n argocd argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 --decode)
```

[http://argocd.localhost](http://argocd.localhost/login?return_url=http%3A%2F%2Fargocd.localhost%2Fapplications)

Username: `admin`

## Grafana

```bash
kubectl config use-context k8slab-janeops
echo $(kubectl get secret -n monitoring monitoring-stack-grafana -o jsonpath="{.data.admin-password}" | base64 --decode)
```

http://grafana.localhost

<!-- FUNCTION down -->
## Down

### Uninstalling cluster tools

```bash
# Uninstalling cluster tools that were installed with argocd
kubectl --token=$(cat argocd-application-deployer.token) --server=$(cat cluster-endpoint.txt) \
delete \
-n argocd \
-f argocd/toolkit-applications/ \
-l selection=toolkit-applications

# Uninstalling argocd stack and its dependencies
terraform -chdir=cluster-tools \
destroy \
-var cluster_ca_certificate=../cluster-ca.crt \
-var service_account_token=../cluster-tools-installer.token \
-var cluster_endpoint=$(cat cluster-endpoint.txt) \
-auto-approve
```

### Revoking user credentials

```bash
# TODO How to revoke user certificates?
```

### Deleting RBAC resources

```bash
kubectl config use-context k8slab-root
kubectl delete -f rbac -l selection=rbac
```

### Destroying local cluster

```bash
terraform -chdir=local-cluster destroy -auto-approve
```

<!-- FUNCTION clean -->
## Clean

```bash
docker ps -a --format "{{.Names}}" | grep "^k8slab-" | while read -r container_name; do
    docker stop "$container_name" >/dev/null 2>&1
    docker rm "$container_name" >/dev/null 2>&1
done

(cd local-cluster; git clean -Xfd)
(cd cluster-tools; git clean -Xfd)

git clean -Xf
```
