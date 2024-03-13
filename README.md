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

## Local cluster

### Provisioning local cluster with Terraform (~2 minutes)

Provisioning a KinD (Kubernetes-in-Docker) cluster in the local environment using Terraform.
You could use the `kind` CLI to create the cluster, but to make it more like a real environment, we will use Terraform.

```bash
tfenv install 1.7.3
tfenv use 1.7.3

terraform -chdir=local-cluster init

TF_LOG="INFO" \
terraform -chdir=local-cluster apply -auto-approve
```

## Role-Based Access Control (RBAC)

### Retrieving cluster credentials

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

### Setting cluster entry in kubeconfig

When you create a KinD cluster, a kubeconfig file is automatically configured to access the cluster, but we won't use it. Instead, we will set up the kubeconfig from scratch.

```bash
# Setting cluster entry in kubeconfig
kubectl config set-cluster k8slab --server=$(cat cluster-endpoint.txt) --certificate-authority=cluster-ca.crt --embed-certs=true
```

### Setting root user in kubeconfig

```bash
# Setting user entry in kubeconfig
kubectl config set-credentials k8slab-root --client-key=root.key --client-certificate=root.crt --embed-certs=true

# Setting context entry in kubeconfig
kubectl config set-context k8slab-root --cluster=k8slab --user=k8slab-root

# Switching to root user
kubectl config use-context k8slab-root
```

### Granting user credentials

Let's create two dummy users:

- John Dev, who will be given the 'developer' role.
- Jane Ops, who will be given the 'administrator' cluster-role.

#### Generating private keys and Certificate Signing Request (CSR) files

```bash
# Generating private keys
openssl genrsa -out johndev.key 2048
openssl genrsa -out janeops.key 2048

# Generating CSR files
openssl req -new -key johndev.key -out johndev.csr -subj "/CN=John Dev"
openssl req -new -key janeops.key -out janeops.csr -subj "/CN=Jane Ops"
```

#### Signing certificates

```bash
# Signing certificates
openssl x509 -req -in johndev.csr -CA cluster-ca.crt -CAkey cluster-ca.key -CAcreateserial -out johndev.crt -days 1
openssl x509 -req -in janeops.csr -CA cluster-ca.crt -CAkey cluster-ca.key -CAcreateserial -out janeops.crt -days 1
```

#### Setting user credentials in kubeconfig

```bash
# Setting user entries in kubeconfig
kubectl config set-credentials k8slab-johndev --client-key=johndev.key --client-certificate=johndev.crt --embed-certs=true
kubectl config set-credentials k8slab-janeops --client-key=janeops.key --client-certificate=janeops.crt --embed-certs=true

# Setting context entries in kubeconfig
kubectl config set-context k8slab-johndev --cluster=k8slab --user=k8slab-johndev
kubectl config set-context k8slab-janeops --cluster=k8slab --user=k8slab-janeops
```

### Applying RBAC resources

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

### Retrieving service account tokens

In a real environment, these tokens would typically be incorporated into the CI/CD secrets.
However, for the purposes of this simulation, let's store them in files instead.

```bash
# Retrieving cluster-tools-installer service account token
kubectl get secret cluster-tools-installer -o jsonpath='{.data.token}' | base64 --decode > cluster-tools-installer.token

# Retrieving argocd-application-deployer service account token
kubectl get secret argocd-application-deployer -n argocd -o jsonpath='{.data.token}' | base64 --decode > argocd-application-deployer.token
```

## Cluster tools

Cluster tools is a collection of Helm charts that extend the functionality of the Kubernetes cluster,
improving deployments, security, networking, monitoring, etc.,
by adding tools such as Argo CD, Prometheus, Grafana, Loki, Trivy Operator, Ingress NGINX Controller, and more.

These tools can be installed in 3 ways:

- Using Helm
- Using Terraform
- Using Argo CD (in this case, Argo CD must be installed first with Helm or Terraform)

We'll use Terraform to install Argo CD and then use Argo CD to install the other tools.

### Setting the maximum number of file system notification subscribers

The `fs.inotify` Linux kernel subsystem can be used to register for notifications when specific files or directories are modified, accessed, or deleted.

Let's increase the value of the `fs.inotify.max_user_instances` parameter to prevent some containers in the monitoring stack from crashing due to "too many open files" while watching for changes in the log files.

Since both host and containers share the same kernel, configuring it on the host also applies to the Docker containers that KinD uses as cluster nodes, and also to the pod's containers running inside those nodes.

This value is reset when the system restarts.

TODO Move it to a pod initializer

```bash
if [ $(sysctl -n fs.inotify.max_user_instances) -lt 1024 ]; then
  docker run -it --rm --privileged alpine sysctl -w fs.inotify.max_user_instances=1024
fi
```

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

### Argo CD CLI login

TODO Using the --grpc-web flag because ingressGrpc is not yet configured

```bash
argocd login --grpc-web --insecure \
argocd.localhost \
--username admin \
--password $(kubectl --context k8slab-janeops get secret -n argocd argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 --decode)
```

### Installing cluster tools with Argo CD

```bash
kubectl --token=$(cat argocd-application-deployer.token) --server=$(cat cluster-endpoint.txt) \
apply -n argocd -f argocd/toolkit-applications/ \
--prune -l selection=toolkit-applications \
--prune-allowlist=argoproj.io/v1alpha1/Application
```

### Waiting cluster tools synchronization (~20 minutes)

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

### Accessing Argo CD

After installing Argo CD with Terraform,
you can access its user interface in your browser:

- [http://argocd.localhost](http://argocd.localhost/login?return_url=http%3A%2F%2Fargocd.localhost%2Fapplications)

```bash
# Retrieving 'admin' password
echo $(kubectl --context k8slab-janeops get secret -n argocd argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 --decode) > argocd-admin.password
```

### Accessing Grafana

After installing the cluster tools with Argo CD and synchronizing the monitoring-stack,
you can access Grafana in your browser:

- [http://grafana.localhost](http://grafana.localhost)

```bash
# Retrieving 'admin' password
echo $(kubectl --context k8slab-janeops get secret -n monitoring monitoring-stack-grafana -o jsonpath="{.data.admin-password}" | base64 --decode) > grafana-admin.password
```

### Accessing Prometheus

After installing the cluster tools with Argo CD and synchronizing the monitoring-stack,
you can access Prometheus in your browser:

- [http://prometheus.localhost](http://prometheus.localhost)

## Applications

### Hello World

The Hello World application is a simple web application that displays a greeting message.
The default greeting message is `Hello, World!`,
but it can be configured to display a different message.

We'll use the Argo-CD application-set resource to generate 3 Hello World applications,
one for each environment (development, staging, production).

Each application is configured to display a unique message,
accessible via a distinct URL,
and deployed with a different number of replicas.

In a real setup each environment could have a dedicated cluster,
but in this simulation they are isolated by namespace.

Applications:
- `hello-world-dev` - deployed with `2` replicas in the `development` namespace, displays `Hello, Devs!` at `http://dev.localhost/hello`
- `hello-world-stg` - deployed with `4` replicas in the `staging` namespace, displays `Hello, QA Folks!` at `http://stg.localhost/hello`
- `hello-world-prd` - deployed with `8` replicas in the `production` namespace, displays `Hello, Users!` at `http://hello.localhost`

Each application contains the following resources:
- 1 deployment with configurable number of replicas
- 1 service
- 1 ingress with configurable host and path
- 1 config-map to configure the greeting message

TODO
- Use Kustomize instead of Helm for the deployable app
- Remove the service monitor

#### Applying Hello World application-set

```bash
kubectl --token=$(cat argocd-application-deployer.token) --server=$(cat cluster-endpoint.txt) \
apply -n argocd -f argocd/application-sets/ \
--prune -l selection=application-sets \
--prune-allowlist=argoproj.io/v1alpha1/ApplicationSet
```

#### Waiting for Hello World applications synchronization

```bash
argocd app wait -l selection=application-sets
```

#### Waiting for Hello World applications health

```bash
urls="
http://dev.localhost/hello/healthz
http://stg.localhost/hello/healthz
http://hello.localhost/healthz
"
max_retries=3
retry_interval=10
for url in $urls; do
  retries=0
  until [ "$(curl -s -o /dev/null -w '%{http_code}' $url)" = "200" ]; do
    ((++retries));
    if [ $retries -ge $max_retries ]; then exit 1
    else sleep $retry_interval; fi
  done
done
```

#### Interacting with Hello World applications

Open in your browser:
- http://dev.localhost/hello
- http://stg.localhost/hello/
- http://hello.localhost

You can also interact with Hello World applications using `curl`:

```bash
curl http://dev.localhost/hello
curl http://stg.localhost/hello/
curl http://hello.localhost
```

### Python CRUD

Resources:
- 4 services (item-creator, item-reader, item-updater, item-deleter)
- 4 deployments (one for each service)
- 1 stateful-set, 1 service, 1 secret - for MongoDB
- 1 ingress for crud.localhost with 4 paths (one path for each service)
- 4 cron-jobs to run the clients (one client for each service)
- 4 service monitors (one for each service)
- 1 config map for Grafana dashboard

TODO Use application-set instead of application-template for the argocd apps?

#### Deploying Python CRUD

```bash
creds="--kube-apiserver $(cat cluster-endpoint.txt) --kube-token $(cat argocd-application-deployer.token)"
helm $creds list --short -n argocd | grep -q '^argocd-apps$' \
&& helm $creds upgrade argocd-apps -n argocd argocd/application-templates \
|| helm $creds install argocd-apps -n argocd argocd/application-templates
```

#### Waiting for Python CRUD application synchronization

```bash
argocd app wait -l selection=application-templates
```

#### Waiting for Python CRUD application health

```bash
urls="
http://crud.localhost/item-creator/healthz
http://crud.localhost/item-reader/healthz
http://crud.localhost/item-updater/healthz
http://crud.localhost/item-deleter/healthz
"
max_retries=3
retry_interval=10
for url in $urls; do
  retries=0
  until [ "$(curl -s -o /dev/null -w '%{http_code}' $url)" = "200" ]; do
    ((++retries));
    if [ $retries -ge $max_retries ]; then exit 1
    else sleep $retry_interval; fi
  done
done
```

#### Interacting with Python CRUD's API

Get all items:

- http://crud.localhost/item-reader/api/items/.*

You can interact with Python CRUD's API using `curl`:

```bash
# Create item with name=FooBar
curl -X POST \
-H "Content-Type: application/json" \
-d '{"name":"FooBar"}' \
http://crud.localhost/item-creator/api/items

# Read items with name=FooBar
curl -X GET \
http://crud.localhost/item-reader/api/items/%5EFooBar%24

# Update items with name=FooBar to name=BarFoo
curl -X PUT \
-H "Content-Type: application/json" \
-d '{"name":"BarFoo"}' \
http://crud.localhost/item-updater/api/items/%5EFooBar%24

# Delete items with name=BarFoo
curl -X DELETE \
http://crud.localhost/item-deleter/api/items/%5EBarFoo%24
```

#### Dashboards

- http://grafana.localhost/d/pycrud

#### Logs

Logs for the last 30 minutes in the 'python-crud' namespace:
- Grafana >> Explore >> Select datasource: `loki` >> Select label: `namespace` >> Select value: `python-crud` >> Select range: `Last 30 minutes` >> Run query
- http://grafana.localhost/explore?schemaVersion=1&orgId=1&panes=%7B%22dHt%22%3A%7B%22datasource%22%3A%22loki%22%2C%22queries%22%3A%5B%7B%22refId%22%3A%22A%22%2C%22expr%22%3A%22%7Bnamespace%3D%5C%22python-crud%5C%22%7D%20%7C%3D%20%60%60%22%2C%22queryType%22%3A%22range%22%2C%22datasource%22%3A%7B%22type%22%3A%22loki%22%2C%22uid%22%3A%22loki%22%7D%2C%22editorMode%22%3A%22builder%22%7D%5D%2C%22range%22%3A%7B%22from%22%3A%22now-30m%22%2C%22to%22%3A%22now%22%7D%7D%7D

#### Status

Health check:
- http://crud.localhost/item-creator/healthz
- http://crud.localhost/item-reader/healthz
- http://crud.localhost/item-updater/healthz
- http://crud.localhost/item-deleter/healthz

Service monitor targets:
- Prometheus >> Status >> Targets >> Filter by endpoint or labels: `python-crud`
- http://prometheus.localhost/targets?search=python-crud

#### Metrics

Current number of items (gauge):
- `sum(pycrud_items_total)`
- http://prometheus.localhost/graph?g0.expr=sum(pycrud_items_total)

Successfully created items (counter):
- `sum(pycrud_http_requests_total{method="POST", status="200"})`
- http://prometheus.localhost/graph?g0.expr=sum(pycrud_http_requests_total%7Bmethod%3D%22POST%22%2C%20status%3D%22200%22%7D)

Average duration of successful item read requests (summary):
- `avg(pycrud_http_request_duration_seconds_sum{method="GET", status="200"})`
- http://prometheus.localhost/graph?g0.expr=avg(pycrud_http_request_duration_seconds_sum%7Bmethod%3D%22GET%22%2C%20status%3D%22200%22%7D)

Average database latency by operation (summary):
- `avg by (operation) (pycrud_database_latency_seconds_sum)`
- http://prometheus.localhost/graph?g0.expr=avg%20by%20(operation)%20(pycrud_database_latency_seconds_sum)

Other examples:
- All requests: `sum(pycrud_http_requests_total)`
- Requests by method and status: `sum by (method, status) (pycrud_http_requests_total)`
- Item creation requests by status: `sum by (status) (pycrud_http_requests_total{method="POST"})`
- Items failed to create due to client error: `sum(pycrud_http_requests_total{method="POST", status="400"})`
- Items failed to create due to server error: `sum(pycrud_http_requests_total{method="POST", status="500"})`
- Successful requests by method: `sum by (method) (pycrud_http_requests_total{status="200"})`

<!-- ----------------------------------------------------------------------- -->
<!-- FUNCTION drop -->
## Drop

### Undeploying applications

```bash
# python-crud
helm --kube-apiserver $(cat cluster-endpoint.txt) --kube-token $(cat argocd-application-deployer.token) \
uninstall argocd-apps -n argocd

# hello-world
kubectl --server=$(cat cluster-endpoint.txt) --token=$(cat argocd-application-deployer.token) \
delete \
-n argocd \
-f argocd/application-sets/ \
-l selection=application-sets
```

### Uninstalling cluster tools

```bash
# Uninstalling cluster tools that were installed with argocd
kubectl --server=$(cat cluster-endpoint.txt) --token=$(cat argocd-application-deployer.token) \
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

TODO How to revoke user certificates?

### Deleting RBAC resources

```bash
kubectl --context k8slab-root delete -f rbac/ -l selection=rbac
```

### Destroying local cluster

```bash
terraform -chdir=local-cluster destroy -auto-approve
```

<!-- ----------------------------------------------------------------------- -->
<!-- FUNCTION nuke -->
## Nuke

```bash
# Stopping and removing Docker containers used as cluster nodes
docker ps -a --format "{{.Names}}" | grep "^k8slab-" | while read -r container_name; do
    docker stop "$container_name" >/dev/null 2>&1
    docker rm "$container_name" >/dev/null 2>&1
done

# Removing gitignored files
(cd local-cluster; git clean -Xfd)
(cd cluster-tools; git clean -Xfd)
git clean -Xf
```

<!-- ----------------------------------------------------------------------- -->
## Ref

PromQL (Prometheus Query Language) examples:
- https://prometheus.io/docs/prometheus/latest/querying/examples/

## TODO

### Grafana showing "too many outstanding requests" error while querying Loki datasource

- https://stackoverflow.com/questions/74568197/grafana-showing-too-many-outstanding-requests-error-while-querying-loki-dashbo
- https://github.com/grafana/loki/issues/5123
- https://community.grafana.com/t/too-many-outstanding-requests-on-loki-2-7-1/78249/8

### How to return from xdg-open within a shell script

- https://unix.stackexchange.com/questions/74605/use-xdg-open-to-open-a-url-with-a-new-process
- https://askubuntu.com/questions/1345259/how-to-return-from-xdg-open-within-a-shell-script

### Prometheus data storage, retention, etc

### Protect Prometheus endpoint? Teleport?

### Trivy Operator Dashboard in Grafana

https://aquasecurity.github.io/trivy-operator/v0.11.0/tutorials/grafana-dashboard/

### Why these Prometheus targets are unhealthy?

- serviceMonitor/monitoring/monitoring-stack-kube-prom-kube-controller-manager/0 (0/1 up)
- serviceMonitor/monitoring/monitoring-stack-kube-prom-kube-etcd/0 (0/1 up)
- serviceMonitor/monitoring/monitoring-stack-kube-prom-kube-proxy/0 (0/3 up)
- serviceMonitor/monitoring/monitoring-stack-kube-prom-kube-scheduler/0 (0/1 up)

### PyCRUD metrics

Gauge pycrud_items_total
- pycrud_items_total

Counter pycrud_http_requests_total (`method` (POST, GET, PUT, DELETE), `status` (200, 400, 500))
- pycrud_http_requests_created
- pycrud_http_requests_total

Summary pycrud_http_request_duration_seconds (`method` (POST, GET, PUT, DELETE), `status` (200, 400, 500))
- pycrud_http_request_duration_seconds_created
- pycrud_http_request_duration_seconds_count
- pycrud_http_request_duration_seconds_sum

Summary pycrud_database_latency_seconds (`operation` (create_one_item, read_many_items, update_many_items, delete_many_items))
- pycrud_database_latency_seconds_created
- pycrud_database_latency_seconds_count
- pycrud_database_latency_seconds_sum
