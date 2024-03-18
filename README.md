# K8sLab

A project designed to explore and experiment with a local [Kubernetes](https://kubernetes.io/) cluster
bundled with popular open-source tools and example applications,
simulating a real platform.

The simulation includes:

- [Terraform](https://www.terraform.io/) for resource provisioning
- [Helm](https://helm.sh/) for package management
- [Argo CD](https://argoproj.github.io/cd/) for continuous deployment
- [Ingress-Nginx Controller](https://kubernetes.github.io/ingress-nginx/) for traffic routing
- [Prometheus](https://prometheus.io/) for metrics and alerts
- [Grafana](https://grafana.com/grafana/) for dashboard visualization
- [Grafana Loki](https://grafana.com/oss/loki/) for log aggregation
- [Trivy Operator](https://aquasecurity.github.io/trivy-operator) for continuous security scan

Run the simulation by following these steps:

1. CLI Tools Installation
2. Cluster Provisioning
3. RBAC and Namespace Configuration
4. Cluster Tools Installation
5. Application Deployment
6. Cleanup and Tear Down

To execute these steps automatically, use the [`run.sh`](./run.sh) script:

- `./run.sh up`
- `./run.sh down`

## 1. CLI Tools Installation

This step involves installing the necessary command-line interface (CLI) tools required for managing and interacting with your local Kubernetes environment.

CLI tools:

- `terraform`
- `kubectl`
- `helm`
- `argocd`

The required versions of these tools are defined in the [`.tool-versions`](./.tool-versions) file.

You can use the [asdf](https://asdf-vm.com/) version manager to install these tools:

```bash
# Add asdf plugins
asdf plugin add terraform
asdf plugin add kubectl
asdf plugin add helm
asdf plugin add argocd

# Install tools defined in .tool-versions file
asdf install
```

## 2. Cluster Provisioning

This step involves creating the Kubernetes cluster itself.

We'll create a [KinD](https://kind.sigs.k8s.io/) (Kubernetes-in-Docker) cluster,
which is a local Kubernetes cluster that uses Docker containers as cluster nodes.

We could use the `kind` CLI tool to create the cluster,
but we will use `terraform` to make it more like a real environment.

The local cluster Terraform configuration is defined in the [`local-cluster`](./local-cluster) directory.

```bash
terraform -chdir=local-cluster init

TF_LOG="INFO" \
terraform -chdir=local-cluster apply -auto-approve
```

## 3. RBAC and Namespace Configuration

This step involves configuring Role-Based Access Control (RBAC) resources,
as well as setting namespace limit ranges and resource quotas.

KinD automatically sets up a kubeconfig to access the cluster, but we won't use it.
Instead, we will set up the kubeconfig from scratch.

### Retrieving cluster credentials

```bash
# Retrieving cluster endpoint
terraform -chdir=local-cluster output -raw endpoint > cluster-endpoint.txt

# Retrieving cluster CA key
terraform -chdir=local-cluster output -raw ca_key > cluster-ca.key

# Retrieving cluster CA certificate
terraform -chdir=local-cluster output -raw ca_certificate > cluster-ca.crt
```

### Retrieving root user credentials

```bash
# Retrieving root user key
terraform -chdir=local-cluster output -raw root_user_key > root.key

# Retrieving root user certificate
terraform -chdir=local-cluster output -raw root_user_certificate > root.crt
```

### Grating cluster operators access

Cluster operators are cluster-level users and service accounts that will be given cluster roles.

```bash
cluster_root_user_credentials_terraform="
  -var cluster_endpoint=$(cat cluster-endpoint.txt)
  -var cluster_ca_certificate=$(realpath cluster-ca.crt)
  -var root_user_key=$(realpath root.key)
  -var root_user_certificate=$(realpath root.crt)
"

terraform -chdir=cluster-operators init

TF_LOG=INFO \
terraform -chdir=cluster-operators \
apply $cluster_root_user_credentials_terraform \
-auto-approve
```

### Retrieving cluster-level service account tokens

In a real environment, these tokens would typically be incorporated into CI/CD secrets.
However, for the purposes of this simulation, let's store them in files instead.

```bash
# Retrieving namespace-manager service account token
terraform -chdir=cluster-operators output -raw namespace_manager_token > namespace-manager.token

# Retrieving cluster-tools-installer service account token
terraform -chdir=cluster-operators output -raw cluster_tools_installer_token > cluster-tools-installer.token
```

### Setting cluster entry in kubeconfig

```bash
# Setting cluster entry in kubeconfig
kubectl config set-cluster k8slab --server=$(cat cluster-endpoint.txt) --certificate-authority=$(realpath cluster-ca.crt) --embed-certs=true
```

### Setting root user in kubeconfig

```bash
# Setting user entry in kubeconfig
kubectl config set-credentials k8slab-root --client-key=root.key --client-certificate=root.crt --embed-certs=true

# Setting context entry in kubeconfig
kubectl config set-context k8slab-root --cluster=k8slab --user=k8slab-root
```

### Applying namespace-configs

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

### Retrieving namespace-level service account tokens

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

### Granting user credentials

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

## 4. Cluster Tools Installation

This step involves installing various Helm charts that extend the functionality of the Kubernetes cluster,
improving security, networking, monitoring, deployment process, etc.,
by adding tools such as Argo CD, Prometheus, Grafana, Loki, Promtail, Trivy Operator, Ingress NGINX Controller, and more.

These tools can be installed in 3 ways:

- Using Helm
- Using Terraform
- Using Argo CD (in this case, Argo CD must be installed first with Helm or Terraform)

Let's use Terraform!

Before proceeding with the installation,
execute each of the following commands in a new tab in your terminal to watch the pods start up:

- `watch -n 1 kubectl get pods --namespace ingress`
- `watch -n 1 kubectl get pods --namespace monitoring`
- `watch -n 1 kubectl get pods --namespace trivy`
- `watch -n 1 kubectl get pods --namespace argocd`

### Installing cluster tools with Terraform

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
-parallelism=1
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

## 5. Application Deployment

This step involves deploying example applications onto the Kubernetes cluster.

We'll deploy two applications:

- `Hello World` - a simple web application that will be deployed in multiple environments (development, staging, and production)
- `CRUDify` - a microservices-based CRUD application to explore with the cluster features (ingress routing, logging, metrics, etc)

The source-code of the applications reside in the [apps](./apps/) directory.

GitHub Actions workflows are configured to test, build and push the Docker images of the applications to Docker Hub.

The deployment configuration of the applications reside in the [deployable-apps](./deployable-apps/) directory.

Argo CD watches the deployment configurations to deploy and synchronize changes onto the cluster.

### Hello World

The Hello World application is a simple web application that displays a greeting message.

The default greeting message is `Hello, World!`,
but it can be configured to display a different message.

We'll use the Argo CD ApplicationSet resource to generate 3 Hello World applications,
one for each environment (development, staging, and production).

Each application is configured to display a unique message,
accessible via a distinct URL,
and deployed with a different number of replicas.

Applications:

- `hello-world-dev` - deployed with `2` replicas in the `development` namespace, displays `Hello, Devs!` at `http://dev.localhost/hello`
- `hello-world-stg` - deployed with `4` replicas in the `staging` namespace, displays `Hello, QA Folks!` at `http://stg.localhost/hello`
- `hello-world-prd` - deployed with `8` replicas in the `production` namespace, displays `Hello, Users!` at `http://hello.localhost`

Each application contains the following resources:

- 1 deployment with configurable number of replicas
- 1 service
- 1 ingress with configurable host and path
- 1 config-map to configure the greeting message

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

- [http://crud.localhost/item-reader/api/items/.*](http://crud.localhost/item-reader/api/items/.*)

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

<!-- FUNCTION drop -->
## 6. Cleanup and Tear Down

This step involves dismantling and removing all components and configurations associated with the Kubernetes cluster.
It includes undeploying applications, uninstalling cluster-wide tools, and removing RBAC and namespace configurations.
Finally, the Kubernetes cluster itself is destroyed.

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
cluster_tools_installer_credentials_terraform="
  -var cluster_endpoint=$(cat cluster-endpoint.txt)
  -var cluster_ca_certificate=$(realpath cluster-ca.crt)
  -var service_account_token=$(realpath cluster-tools-installer.token)
"

terraform -chdir=cluster-tools \
destroy $cluster_tools_installer_credentials_terraform \
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

<!-- FUNCTION nuke -->
### Nuke

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
