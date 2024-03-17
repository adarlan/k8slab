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

## Installing CLI tools

Using the `asdf` version manager to install the CLI tools defined in the [.tool-versions](./.tool-versions) file.

```bash
while IFS= read -r toolVersion; do
  asdf plugin add $(echo $toolVersion | awk '{print $1}')
  asdf install $toolVersion
done < .tool-versions
```

## Provisioning local cluster (~2 minutes)

Provisioning a KinD (Kubernetes-in-Docker) cluster in your local environment.

You could use the `kind` CLI tool to create the cluster,
but we will use `terraform` to make it more like a real environment.

The local cluster Terraform configuration is defined in the [local-cluster](./local-cluster) directory.

```bash
terraform -chdir=local-cluster init

TF_LOG="INFO" \
terraform -chdir=local-cluster apply -auto-approve
```

## Retrieving cluster credentials

The directory `/etc/kubernetes/pki/` of a control-plane node typically contains the Public Key Infrastructure (PKI) assets used by the Kubernetes control-plane components for secure communication and authentication within the cluster.

```bash
# Retrieving cluster's Certificate Authority (CA) key
docker cp k8slab-control-plane:/etc/kubernetes/pki/ca.key cluster-ca.key

# Retrieving cluster's Certificate Authority (CA) certificate
docker cp k8slab-control-plane:/etc/kubernetes/pki/ca.crt cluster-ca.crt

# Retrieving cluster's endpoint
terraform -chdir=local-cluster output -raw endpoint > cluster-endpoint.txt
```

## Setting cluster entry in kubeconfig

KinD automatically sets up a kubeconfig to access the cluster, but we won't use it.
Instead, we will set up the kubeconfig from scratch.

```bash
# Setting cluster entry in kubeconfig
kubectl config set-cluster k8slab \
--server=$(cat cluster-endpoint.txt) \
--certificate-authority=cluster-ca.crt \
--embed-certs=true
```

## Retrieving root user credentials

```bash
# Retrieving root user key
terraform -chdir=local-cluster output -raw root_user_key > root.key

# Retrieving root user certificate
terraform -chdir=local-cluster output -raw root_user_certificate > root.crt
```

## Setting root user in kubeconfig

```bash
# Setting user entry in kubeconfig
kubectl config set-credentials k8slab-root --client-key=root.key --client-certificate=root.crt --embed-certs=true

# Setting context entry in kubeconfig
kubectl config set-context k8slab-root --cluster=k8slab --user=k8slab-root
```

## Grating cluster operators access

Cluster operators are cluster-level users and service accounts that will be given cluster roles.

```bash
cluster_root_user_credentials_helm="
  --kube-context=k8slab-root
"

release=cluster-operators
chart=./cluster-operators
values=./cluster-operators/values.yaml
namespace=cluster-operators

list=$(helm $cluster_root_user_credentials_helm list --short -n $namespace)
echo "$list" | grep -q "^$release$" \
&& helm $cluster_root_user_credentials_helm upgrade $release --values $values $chart -n $namespace \
|| helm $cluster_root_user_credentials_helm install $release --values $values $chart -n $namespace --create-namespace
```

## Retrieving cluster-level service account tokens

In a real environment, these tokens would typically be incorporated into CI/CD secrets.
However, for the purposes of this simulation, let's store them in files instead.

```bash
cluster_root_user_credentials_kubectl="
  --context=k8slab-root
"

# Retrieving namespace-manager service account token
kubectl $cluster_root_user_credentials_kubectl \
get secret namespace-manager --namespace namespace-manager \
-o jsonpath='{.data.token}' | base64 --decode > namespace-manager.token

# Retrieving cluster-tools-installer service account token
kubectl $cluster_root_user_credentials_kubectl \
get secret cluster-tools-installer --namespace cluster-tools-installer \
-o jsonpath='{.data.token}' | base64 --decode > cluster-tools-installer.token
```

## Applying namespace-configs

Configuring namespaces, as well as their:
- service accounts,
- service account secrets,
- roles,
- user and service account role bindings,
- resource quotas,
- and limit ranges.

```bash
namespace_manager_credentials_helm="
  --kube-apiserver=$(cat cluster-endpoint.txt)
  --kube-ca-file=cluster-ca.crt
  --kube-token=$(cat namespace-manager.token)
"

release=namespace-configs
chart=./namespace-configs
values=./namespace-configs/values.yaml
namespace=namespace-configs

list=$(helm $namespace_manager_credentials_helm list --short -n $namespace)
echo "$list" | grep -q "^$release$" \
&& helm $namespace_manager_credentials_helm upgrade $release --values $values $chart -n $namespace \
|| helm $namespace_manager_credentials_helm install $release --values $values $chart -n $namespace --create-namespace
```

## Retrieving namespace-level service account tokens

```bash
namespace_manager_credentials_kubectl="
  --server=$(cat cluster-endpoint.txt)
  --certificate-authority=cluster-ca.crt
  --token=$(cat namespace-manager.token)
"

# Retrieving argocd application-deployer service account token
kubectl $namespace_manager_credentials_kubectl \
get secret application-deployer -n argocd \
-o jsonpath='{.data.token}' | base64 --decode > argocd-application-deployer.token
```

## Granting user credentials

To facilitate your interaction with the cluster using the `kubectl` CLI,
we will create dummy user credentials and set up them in kubeconfig.

To simulate a user,
simply run `kubectl config use-context <username>` before your `kubectl` command
or add the `--context <username>` option to your `kubectl` command.

Usernames:

- `johndev`
- `janeops`

```bash
# Generating private keys
openssl genrsa -out johndev.key 2048
openssl genrsa -out janeops.key 2048

# Generating Certificate Signing Request (CSR) files
openssl req -new -key johndev.key -out johndev.csr -subj "/CN=John Dev"
openssl req -new -key janeops.key -out janeops.csr -subj "/CN=Jane Ops"

# Signing certificates
openssl x509 -req -in johndev.csr -CA cluster-ca.crt -CAkey cluster-ca.key -CAcreateserial -out johndev.crt -days 1
openssl x509 -req -in janeops.csr -CA cluster-ca.crt -CAkey cluster-ca.key -CAcreateserial -out janeops.crt -days 1

# Setting user entries in kubeconfig
kubectl config set-credentials k8slab-johndev --client-key=johndev.key --client-certificate=johndev.crt --embed-certs=true
kubectl config set-credentials k8slab-janeops --client-key=janeops.key --client-certificate=janeops.crt --embed-certs=true

# Setting context entries in kubeconfig
kubectl config set-context k8slab-johndev --cluster=k8slab --user=k8slab-johndev
kubectl config set-context k8slab-janeops --cluster=k8slab --user=k8slab-janeops
```

## Cluster tools

Cluster tools is a collection of Helm charts that extend the functionality of the Kubernetes cluster,
improving deployments, security, networking, monitoring, etc.,
by adding tools such as Argo CD, Prometheus, Grafana, Loki, Promtail, Trivy Operator, Ingress NGINX Controller, and more.

These tools can be installed in 3 ways:

- Using Helm
- Using Terraform
- Using Argo CD (in this case, Argo CD must be installed first with Helm or Terraform)

Let's use Helm!

##

We'll use Terraform to install Argo CD and then use Argo CD to install the other tools.

### Installing Argo CD with Terraform (~5 minutes)

We'll use the Terraform `-target` option to limit the operation to only the `helm_release.argocd_stack` resource and its dependencies.
As argocd-stack depends on networking-stack, the networking-stack will also be installed.

As the `-target` option is for exceptional use only,
Terraform will warn "Resource targeting is in effect" and "Applied changes may be incomplete",
but for the purposes of this simulation you can ignore these messages.

```bash
cluster_tools_installer_credentials_terraform="
  -var cluster_endpoint=$(cat cluster-endpoint.txt)
  -var cluster_ca_certificate=$(realpath cluster-ca.crt)
  -var service_account_token=$(realpath cluster-tools-installer.token)
"

terraform -chdir=cluster-tools init

TF_LOG=INFO \
terraform -chdir=cluster-tools \
apply $cluster_tools_installer_credentials_terraform \
-auto-approve \
-parallelism=1 \
-target=helm_release.argocd_stack
```

### Retrieving Argo CD admin password

```bash
cluster_operator_user_credentials_kubectl="
  --context k8slab-janeops
"

kubectl $cluster_operator_user_credentials_kubectl \
get secret argocd-initial-admin-secret -n argocd \
-o jsonpath="{.data.password}" | base64 --decode > argocd-admin.password
```

### Logging in to Argo CD with its CLI tool

TODO Using the --grpc-web flag because ingressGrpc is not yet configured

```bash
argocd_admin_credentials_argocd_login="
  --username admin
  --password $(cat argocd-admin.password)
"

argocd login --grpc-web --insecure argocd.localhost $argocd_admin_credentials_argocd_login
```

### Accessing Argo CD in your browser

- http://argocd.localhost
- Username: `admin`
- The password is stored in the `argocd-admin.password` file

<!-- COMMAND nohup xdg-open http://argocd.localhost > /dev/null 2>&1 -->

### Installing cluster tools with Argo CD

```bash
argocd_application_deployer_credentials_helm="
  --kube-apiserver=$(cat cluster-endpoint.txt)
  --kube-ca-file=$(realpath cluster-ca.crt)
  --kube-token=$(cat argocd-application-deployer.token)
"

release=cluster-tools-argocd-apps
chart=./cluster-tools/.argocd-apps
values=./cluster-tools/.argocd-apps/values.yaml
namespace=argocd

list=$(helm $argocd_application_deployer_credentials_helm list --short -n $namespace)
echo "$list" | grep -q "^$release$" \
&& helm $argocd_application_deployer_credentials_helm upgrade $release --values $values $chart -n $namespace \
|| helm $argocd_application_deployer_credentials_helm install $release --values $values $chart -n $namespace
```

### Waiting security stack synchronization

```bash
argocd app wait security-stack
```

### Waiting monitoring stack synchronization

The monitoring stack usually takes a long time to synchronize,
and its health state usually transitions to 'Degraded' at some point during the synchronization,
causing the `argocd app wait` command to fail, despite the synchronization process continuing.
Because of this we will try to wait two more times.

```bash
retries=0
until argocd app wait monitoring-stack; do
  ((++retries)); if [ $retries -ge 3 ]; then exit 1; fi
done
```

<!-- TODO promtail error:
level=error 
caller=main.go:170 
msg="error creating promtail" 
error="failed to make file target manager: too many open files"
-->

<!-- TODO loki-logs error:
caller=main.go:74 
level=error 
msg="error creating the agent server entrypoint" 
err="unable to apply config for monitoring/monitoring-stack-loki: unable to create logs instance: failed to make file target manager: too many open files"
-->

<!-- https://maestral.app/docs/inotify-limits -->

### Accessing Prometheus in your browser

- http://prometheus.localhost

<!-- COMMAND nohup xdg-open http://prometheus.localhost > /dev/null 2>&1 -->

### Retrieving Grafana admin password

```bash
cluster_operator_user_credentials_kubectl="
  --context k8slab-janeops
"

kubectl $cluster_operator_user_credentials_kubectl \
get secret monitoring-stack-grafana -n monitoring \
-o jsonpath="{.data.admin-password}" | base64 --decode > grafana-admin.password
```

### Accessing Grafana in your browser

- http://grafana.localhost
- Username: `admin`
- The password is stored in the `grafana-admin.password` file

<!-- COMMAND nohup xdg-open http://grafana.localhost > /dev/null 2>&1 -->

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

### CRUDify

CRUDify is a CRUD (Create, Read, Update, Delete) application written in Python.
Unlike a monolithic application, CRUDify is designed to explore with a microservices architecture,
being composed of distinct components, including multiple services and clients.

CRUDify manages `items`, each consisting of a `name` provided by the client and an `id` assigned by the API.

```json
// Item schema
{
  "id": "string",
  "name": "string"
}
```

Items are uniquely identified by their `id` and validated based on the `name`, which must match the pattern `^[a-zA-Z]{5,30}$`.

CRUDify's API is composed by four services:

- `item-creator`: A service that listens for client requests to create new items in the database.
- `item-reader`: A service that listens for client requests to fetch items from the database.
- `item-updater`: A service that listens for client requests to update items in the database.
- `item-deleter`: A service that listens for client requests to delete items from the database.

The services receive a client request via ingress routing,
perform the requested operation in the database,
generate relevant information in the logs,
update the application metrics,
and return a response to the client.

The API will be accessible at `http://crud.localhost`.
An ingress resource is configured to ensure that incoming traffic directed to `http://crud.localhost/<service-name>` is routed to the corresponding service.

Clients interact with CRUDify's API via HTTP requests:

| Method | URL | Data | Description |
| ------ | --- | ---- | ----------- |
| `POST`   | `http://crud.localhost/item-creator/api/items`         | `{ name: string }` | Creates a new item |
| `GET`    | `http://crud.localhost/item-reader/api/items/<query>`  |                    | Retrieves items matching the query |
| `PUT`    | `http://crud.localhost/item-updater/api/items/<query>` | `{ name: string }` | Updates items matching the query |
| `DELETE` | `http://crud.localhost/item-deleter/api/items/<query>` |                    | Deletes items matching the query |

The `<query>` parameter is a regex used to filter items by name.
For example, `GET http://crud.localhost/item-reader/api/items/.*` retrieves all items.
The query must be URL-encoded to fit the request path.

Four client applications simulate real users:

- `item-creator-client`
- `item-reader-client`
- `item-updater-client`
- `item-deleter-client`

These clients run as batch jobs on a cron schedule.
In each execution, they perform a random number of iterations.
For each iteration, they call the CRUDify API with random queries and data.
Some random-generated data may fail validation, leading to expected bad request errors.

CRUDify uses MongoDB to store the items.
The configuration includes a stateful-set for the MongoDB container.

CRUDify logs are directed to stdout and transiently stored in files on the cluster nodes.
These logs are then collected by Promtail agents and forwarded to the Loki server,
enabling easy visualization of logs through Grafana dashboards.

CRUDify services provide Prometheus metrics for monitoring and performance analysis.
Each service is equipped with its own service monitor,
instructing the Prometheus operator on the targets to scrape for metrics.
The metrics collected from these services can be visualized within Grafana dashboards.

Deploying this application will create the following resources in the cluster:

- 4 services for the API
- 4 deployments (one for each API service)
- 1 stateful-set, 1 service, and 1 secret for MongoDB
- 1 ingress for crud.localhost with 4 paths (one path for each API service)
- 4 cron-jobs to run the clients (one client for each API service)
- 4 service monitors (one for each API service)
- 1 config map for Grafana dashboard

TODO Use application-set instead of application-template for the argocd apps?

#### Deploying CRUDify application

```bash
creds="--kube-apiserver $(cat cluster-endpoint.txt) --kube-token $(cat argocd-application-deployer.token)"
helm $creds list --short -n argocd | grep -q '^argocd-apps$' \
&& helm $creds upgrade argocd-apps -n argocd argocd/application-templates \
|| helm $creds install argocd-apps -n argocd argocd/application-templates
```

#### Waiting for CRUDify application synchronization

```bash
argocd app wait -l selection=application-templates
```

#### Waiting for CRUDify application health

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

#### Interacting with CRUDify's API using curl

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

#### Fetching items in your browser

Fetching all items:

- http://crud.localhost/item-reader/api/items/.*

#### Dashboards

- http://grafana.localhost/d/crudify

#### Logs

Logs for the last 30 minutes in the 'crudify' namespace:
- Grafana >> Explore >> Select datasource: `loki` >> Select label: `namespace` >> Select value: `crudify` >> Select range: `Last 30 minutes` >> Run query
- http://grafana.localhost/explore?schemaVersion=1&orgId=1&panes=%7B%22dHt%22%3A%7B%22datasource%22%3A%22loki%22%2C%22queries%22%3A%5B%7B%22refId%22%3A%22A%22%2C%22expr%22%3A%22%7Bnamespace%3D%5C%22crudify%5C%22%7D%20%7C%3D%20%60%60%22%2C%22queryType%22%3A%22range%22%2C%22datasource%22%3A%7B%22type%22%3A%22loki%22%2C%22uid%22%3A%22loki%22%7D%2C%22editorMode%22%3A%22builder%22%7D%5D%2C%22range%22%3A%7B%22from%22%3A%22now-30m%22%2C%22to%22%3A%22now%22%7D%7D%7D

#### Status

Health check:
- http://crud.localhost/item-creator/healthz
- http://crud.localhost/item-reader/healthz
- http://crud.localhost/item-updater/healthz
- http://crud.localhost/item-deleter/healthz

Service monitor targets:
- Prometheus >> Status >> Targets >> Filter by endpoint or labels: `crudify`
- http://prometheus.localhost/targets?search=crudify

#### Metrics

Current number of items (gauge):
- `sum(crudify_items_total)`
- http://prometheus.localhost/graph?g0.expr=sum(crudify_items_total)

Successfully created items (counter):
- `sum(crudify_http_requests_total{method="POST", status="200"})`
- http://prometheus.localhost/graph?g0.expr=sum(crudify_http_requests_total%7Bmethod%3D%22POST%22%2C%20status%3D%22200%22%7D)

Average duration of successful item read requests (summary):
- `avg(crudify_http_request_duration_seconds_sum{method="GET", status="200"})`
- http://prometheus.localhost/graph?g0.expr=avg(crudify_http_request_duration_seconds_sum%7Bmethod%3D%22GET%22%2C%20status%3D%22200%22%7D)

Average database latency by operation (summary):
- `avg by (operation) (crudify_database_latency_seconds_sum)`
- http://prometheus.localhost/graph?g0.expr=avg%20by%20(operation)%20(crudify_database_latency_seconds_sum)

Other examples:
- All requests: `sum(crudify_http_requests_total)`
- Requests by method and status: `sum by (method, status) (crudify_http_requests_total)`
- Item creation requests by status: `sum by (status) (crudify_http_requests_total{method="POST"})`
- Items failed to create due to client error: `sum(crudify_http_requests_total{method="POST", status="400"})`
- Items failed to create due to server error: `sum(crudify_http_requests_total{method="POST", status="500"})`
- Successful requests by method: `sum by (method) (crudify_http_requests_total{status="200"})`

<!-- ----------------------------------------------------------------------- -->
<!-- FUNCTION drop -->
## Drop

### Undeploying applications

```bash
# crudify
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

### Tracing

OpenTelemetry
- https://opentelemetry.io/

Jaeger
- https://www.jaegertracing.io/

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

### CRUDify metrics

Gauge crudify_items_total
- crudify_items_total

Counter crudify_http_requests_total (`method` (POST, GET, PUT, DELETE), `status` (200, 400, 500))
- crudify_http_requests_created
- crudify_http_requests_total

Summary crudify_http_request_duration_seconds (`method` (POST, GET, PUT, DELETE), `status` (200, 400, 500))
- crudify_http_request_duration_seconds_created
- crudify_http_request_duration_seconds_count
- crudify_http_request_duration_seconds_sum

Summary crudify_database_latency_seconds (`operation` (create_one_item, read_many_items, update_many_items, delete_many_items))
- crudify_database_latency_seconds_created
- crudify_database_latency_seconds_count
- crudify_database_latency_seconds_sum

### CRUDify queues

Replace the `item-updater` and `item-deleter` services by the following components:

- `item-updater-dispatcher`: A service that listens for client requests to update items and dispatches individual requests to the __item update queue__.
- `item-updater-worker`: A service that consumes the item update queue via __message queue subscription__ and updates each item in the database.
- `item-deleter-dispatcher`: A service that listens for client requests to delete items and dispatches individual requests to the __item deletion queue__.
- `item-deleter-worker`: A cron-job that consumes the item deletion queue via __pooling__ and deletes each item from the database.

### CRUDify database

NFS Volume
https://github.com/badtuxx/DescomplicandoKubernetes/tree/main/pt/day-6

Prometheus MongoDB Exporter
https://github.com/prometheus-community/helm-charts/tree/main/charts/prometheus-mongodb-exporter

MongoDB Community Kubernetes Operator
https://github.com/mongodb/mongodb-kubernetes-operator

### CRUDify authentication and authorization

### CRUDify client metrics

For cron jobs, exposing metrics via an endpoint isn't feasible due to their short-lived nature.
Explore alternative monitoring strategies to ensure comprehensive metric collection.

### CRUDify Alerts

PrometheusRule?

### CRUDify Horizontal Pod Autoscaler

HPA
