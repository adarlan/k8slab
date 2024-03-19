# K8sLab

A project intended for exploring with a local [Kubernetes](https://kubernetes.io/) cluster
bundled with popular open-source tools and example applications,
simulating a real environment.

This simulation includes:

1. Cluster Provisioning
2. Cluster-Level RBAC
3. Namespace Provisioning
4. Namespace-Level RBAC
5. Cluster Toolkit Installation
6. Application Deployment

### Features

- [Terraform](https://www.terraform.io/) for resource provisioning
- [Helm](https://helm.sh/) for manifest files generation
- [Kustomize](https://kustomize.io/) for deployment configuration
- [Argo CD](https://argoproj.github.io/cd/) for continuous deployment
- [Ingress-Nginx Controller](https://kubernetes.github.io/ingress-nginx/) for traffic routing
- [Prometheus](https://prometheus.io/) for metrics and alerts
- [Grafana](https://grafana.com/grafana/) for dashboard visualization
- [Grafana Loki](https://grafana.com/oss/loki/) for log aggregation

### Example Applications

To explore with the cluster features,
we will deploy two example applications:

- Hello World: A simple web application that displays a greeting message and will be deployed across multiple environments with distinct configuration.
- CRUDify: A microservice-based CRUD application composed by multiple services and clients designed to experiment with the cluster's capabilities.

### Requirements

- Docker Engine
- Terraform CLI (`terraform`)
- Kubernetes CLI (`kubectl`)
- Argo CD CLI (`argocd`)

The recommended versions of the CLI tools are defined in the [`.tool-versions`](./.tool-versions) file.

### Simulation Steps

Run the simulation by following the step-by-step guide below.

To execute the steps automatically,
use the [`run.sh`](./run.sh) script:

- `./run.sh up` to run all steps from cluster provisioning to application deployment.
- `./run.sh down` to remove resources and destroy the cluster.

<!-- BEGIN up -->
<!-- BEGIN local-cluster -->

## 1. Cluster Provisioning

This step involves creating the Kubernetes cluster itself.

We'll create a [KinD](https://kind.sigs.k8s.io/) (Kubernetes-in-Docker) cluster,
which is a local Kubernetes cluster that uses Docker containers as cluster nodes.

We could use the `kind` CLI tool to create the cluster,
but we will use `terraform` to make it more like a real environment.

The Terraform configuration is defined in the [`local-cluster`](./local-cluster) directory.

```bash
terraform -chdir=local-cluster init

TF_LOG="INFO" \
terraform -chdir=local-cluster apply -auto-approve
```

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

echo \
-var cluster_endpoint=$(cat cluster-endpoint.txt) \
-var cluster_ca_certificate=$(realpath cluster-ca.crt) \
-var root_user_key=$(realpath root.key) \
-var root_user_certificate=$(realpath root.crt) \
> root-user.credentials
```

<!-- END local-cluster -->
<!-- BEGIN cluster-operators -->

## 3. Cluster-Level RBAC

This step involves granting cluster operators access.

Cluster operators are cluster-wide users and service accounts that will be given cluster roles.

By default, this action will create:
- the `namespace-manager` service account,
- the `cluster-tools-installer` service account,
- and the `cluster-administrator` cluster role along with a `Jane Ops` user cluster role binding.

You can change this configuration by editing the [`cluster-operators/values.yaml`](./cluster-operators/values.yaml) file.

This is the only action that requires the root user credentials.
After this, we'll have less-privileged users and service accounts to operate the cluster.

```bash
terraform -chdir=cluster-operators init
terraform -chdir=cluster-operators apply $(cat root-user.credentials) -auto-approve
```

### Retrieving namespace manager credentials

Namespace manager is a cluster-wide service account responsible for managing namespace-level configurations.

```bash
terraform -chdir=cluster-operators output -raw namespace_manager_token > namespace-manager.token

echo \
-var cluster_endpoint=$(cat cluster-endpoint.txt) \
-var cluster_ca_certificate=$(realpath cluster-ca.crt) \
-var namespace_manager_token=$(realpath namespace-manager.token) \
> namespace-manager.credentials
```

### Retrieving cluster tools installer credentials

Cluster tools installer is a cluster-wide service account responsible for installing tools that extend the cluster's functionality.

```bash
terraform -chdir=cluster-operators output -raw cluster_tools_installer_token > cluster-tools-installer.token

echo \
-var cluster_endpoint=$(cat cluster-endpoint.txt) \
-var cluster_ca_certificate=$(realpath cluster-ca.crt) \
-var cluster_tools_installer_token=$(realpath cluster-tools-installer.token) \
> cluster-tools-installer.credentials
```

### Signing Jane Ops certificate

Jane Ops is a cluster-wide user responsible for administrating the cluster.

To facilitate your interaction with the cluster using the `kubectl` CLI tool,
we will create Jane Ops' credentials and set up them in your kubeconfig.

To use her credentials,
simply run `kubectl config use-context janeops` before your `kubectl` commands
or add the `--context janeops` option to each `kubectl` command.

<!-- IFNOT kubectl --context janeops auth whoami -->
```bash
# Generating private key
openssl genrsa -out janeops.key 2048

# Generating Certificate Signing Request (CSR) file
openssl req -new -key janeops.key -out janeops.csr -subj "/CN=Jane Ops"

# Signing certificate
openssl x509 -req -in janeops.csr -CA cluster-ca.crt -CAkey cluster-ca.key -CAcreateserial -out janeops.crt -days 1

# Setting cluster entry in kubeconfig
kubectl config set-cluster k8slab --server=$(cat cluster-endpoint.txt) --certificate-authority=$(realpath cluster-ca.crt) --embed-certs=true

# Setting user entry in kubeconfig
kubectl config set-credentials janeops --client-key=janeops.key --client-certificate=janeops.crt --embed-certs=true

# Setting context entry in kubeconfig
kubectl config set-context janeops --cluster=k8slab --user=janeops
```

<!-- END cluster-operators -->
<!-- BEGIN namespace-configs -->

## 4. Namespace-Level RBAC & Resource Management

This step involves configuring namespaces along with their resource quotas, and limit ranges,
and granting namespace-level access for users and service accounts.

By default, this action will create:
- the `argocd`, `ingress`, `monitoring`, and `trivy` namespaces for the cluster tools,
- the `application-deployer` service account in the `argocd` namespace,
- the `development`, `staging`, and `production` namespaces for the applications,
- the `developer` role along with a `John Dev` user role binding in the `development` namespace,
- and resource quotas and limit ranges for all these namespaces.

You can change this configuration by editing the [`namespace-configs/values.yaml`](./namespace-configs/values.yaml) file.

This action requires the namespace manager credentials.

```bash
terraform -chdir=namespace-configs init
terraform -chdir=namespace-configs apply $(cat namespace-manager.credentials) -auto-approve
```

### Retrieving Argo CD application deployer credentials

Argo CD application deployer is a namespace-level service account responsible for managing the `Application` and `ApplicationSet` resources in the `argocd` namespace.

```bash
terraform -chdir=namespace-configs output -raw argocd_application_deployer_token > argocd-application-deployer.token

echo \
--server=$(cat cluster-endpoint.txt) \
--certificate-authority=$(realpath cluster-ca.crt) \
--token=$(cat argocd-application-deployer.token) \
> argocd-application-deployer.credentials
```

### Signing John Dev certificate

John Dev is a namespace-level user responsible for developing applications,
authorized to manage application resources in the `development` namespace.

To facilitate your interaction with these resources using the `kubectl` CLI tool,
we will create John Dev's credentials and set up them in your kubeconfig.

To use his credentials,
simply run `kubectl config use-context johndev` before your `kubectl` commands
or add the `--context johndev` option to each `kubectl` command.

<!-- IFNOT kubectl --context johndev auth whoami -->
```bash
# Generating private key
openssl genrsa -out johndev.key 2048

# Generating Certificate Signing Request (CSR) file
openssl req -new -key johndev.key -out johndev.csr -subj "/CN=John Dev"

# Signing certificate
openssl x509 -req -in johndev.csr -CA cluster-ca.crt -CAkey cluster-ca.key -CAcreateserial -out johndev.crt -days 1

# Setting user entry in kubeconfig
kubectl config set-credentials johndev --client-key=johndev.key --client-certificate=johndev.crt --embed-certs=true

# Setting context entry in kubeconfig
kubectl config set-context johndev --cluster=k8slab --user=johndev
```

<!-- END namespace-configs -->
<!-- BEGIN cluster-tools -->

## 5. Cluster Tools Installation

This step involves installing various Helm charts that extend the functionality of the Kubernetes cluster,
improving networking, deployment, monitoring, security, and more.

The configuration is defined in the [`cluster-tools`](./cluster-tools) directory.

This action requires the cluster tools installer credentials.

### Installing Nginx Ingress Controller

```bash
name=ingress-nginx
terraform -chdir=cluster-tools/$name init
terraform -chdir=cluster-tools/$name apply $(cat cluster-tools-installer.credentials) -auto-approve
```

### Installing Argo CD

```bash
name=argo-cd
terraform -chdir=cluster-tools/$name init
terraform -chdir=cluster-tools/$name apply $(cat cluster-tools-installer.credentials) -auto-approve
```

### Installing Grafana Loki

```bash
name=loki
terraform -chdir=cluster-tools/$name init
terraform -chdir=cluster-tools/$name apply $(cat cluster-tools-installer.credentials) -auto-approve
```

### Installing Promtail Agent

```bash
name=promtail
terraform -chdir=cluster-tools/$name init
terraform -chdir=cluster-tools/$name apply $(cat cluster-tools-installer.credentials) -auto-approve
```

### Installing Kube Prometheus Stack

```bash
name=kube-prometheus-stack
terraform -chdir=cluster-tools/$name init
terraform -chdir=cluster-tools/$name apply $(cat cluster-tools-installer.credentials) -auto-approve
```

### Installing Trivy Operator

```bash
name=trivy-operator
terraform -chdir=cluster-tools/$name init
terraform -chdir=cluster-tools/$name apply $(cat cluster-tools-installer.credentials) -auto-approve
```

### Retrieving Argo CD admin password

```bash
terraform -chdir=cluster-tools/argo-cd output -raw admin_password > argocd-admin.password
```

### Retrieving Grafana admin password

```bash
terraform -chdir=cluster-tools/kube-prometheus-stack output -raw grafana_admin_password > grafana-admin.password
```

### Argo CD CLI login

```bash
argocd login --grpc-web --insecure argocd.localhost --username admin --password $(cat argocd-admin.password)
```

### Accessing Argo CD

- [http://argocd.localhost](http://argocd.localhost)
- Username: `admin`
- The password is stored in the file: `argocd-admin.password`

<!-- COMMAND nohup xdg-open http://argocd.localhost > /dev/null 2>&1 -->
<!-- COMMAND echo argocd-admin.password -->

### Accessing Prometheus

- [http://prometheus.localhost](http://prometheus.localhost)

<!-- COMMAND nohup xdg-open http://prometheus.localhost > /dev/null 2>&1 -->

### Accessing Grafana

- [http://grafana.localhost](http://grafana.localhost)
- Username: `admin`
- The password is stored in the file: `grafana-admin.password`

<!-- COMMAND nohup xdg-open http://grafana.localhost > /dev/null 2>&1 -->
<!-- COMMAND echo grafana-admin.password -->

<!-- END cluster-tools -->
<!-- BEGIN deploy -->

## 6. Application Deployments

This step involves deploying example applications onto the Kubernetes cluster.

We'll deploy two applications:

- `Hello World` - a simple web application that will be deployed in multiple environments (development, staging, and production)
- `CRUDify` - a microservices-based CRUD application to explore with the cluster features (ingress routing, logging, metrics, etc)

The source-code of the applications reside in the [`apps`](./apps/) directory.

GitHub Actions workflows are configured to test, build and push the Docker images of the applications to Docker Hub.

The deployment configuration of the applications reside in the [`deploy`](./deploy/) directory.

Argo CD watches the deployment configurations to deploy and synchronize changes onto the cluster.

<!-- BEGIN hello-world -->

### Hello World

The Hello World application is a simple web application that displays a greeting message.

The default greeting message is `Hello, World!`,
but it can be configured to display a different message.

The application is composed by the following resources:

- 1 `Deployment` with configurable number of replicas
- 1 `Service` targeting the deployment pods
- 1 `Ingress` with configurable host and path targeting the service
- 1 `ConfigMap` to configure the greeting message

We'll use the Argo CD `ApplicationSet` resource to generate 3 Hello World applications,
one for each environment (development, staging, and production).

Each application is configured to display a unique message,
accessible via a distinct URL,
and deployed with a different number of replicas.

| Application      | Namespace     | Replicas | URL                              | Message            |
| ---------------- | ------------- | -------- | -------------------------------- | ------------------ |
| `hello-devs`     | `development` | `2`      | `http://dev.localhost/hello`     | `Hello, Devs!`     |
| `hello-qa-folks` | `staging`     | `4`      | `http://staging.hello.localhost` | `Hello, QA Folks!` |
| `hello-society`  | `production`  | `8`      | `http://hello.localhost`         | `Hello, Society!`  |

You can change this configuration by editing the
[`deploy/hello-world/argocd-application-set.yaml`](./deploy/hello-world/argocd-application-set.yaml)
file.

#### Deploying Hello World

This action requires the Argo CD application deployer credentials.

```bash
kubectl $(cat argocd-application-deployer.credentials) \
apply \
--namespace argocd \
--filename deploy/hello-world/argocd-application-set.yaml
```

#### Waiting synchronization

```bash
argocd app wait --selector appset=hello-world
```

#### Health check

The Hello World application exposes a `/healthz` endpoint,
which serves as a health check interface:

- [`http://dev.localhost/hello/healthz`](http://dev.localhost/hello/healthz)
- [`http://staging.hello.localhost/healthz`](http://staging.hello.localhost/healthz)
- [`http://hello.localhost/healthz`](http://hello.localhost/healthz)

We'll await the return of a `200` HTTP status code from this endpoint.

```bash
urls="http://dev.localhost/hello/healthz
http://staging.hello.localhost/healthz
http://hello.localhost/healthz"

for url in $urls; do
  retries=0
  until [ "$(curl -s -o /dev/null -w '%{http_code}' $url)" = "200" ]; do
    ((++retries));
    if [ $retries -ge 3 ]; then exit 1
    else sleep 10; fi
  done
done
```

#### Accessing the application

Open in your browser:

- [`http://dev.localhost/hello`](http://dev.localhost/hello)
- [`http://staging.hello.localhost`](http://staging.hello.localhost)
- [`http://hello.localhost`](http://hello.localhost)

You can also interact using `curl`:

```bash
curl http://dev.localhost/hello
curl http://staging.hello.localhost
curl http://hello.localhost
```

<!-- END hello-world -->
<!-- BEGIN crudify -->

### CRUDify

CRUDify is a CRUD application written in Python.

This application manages `items`.

The API exposes four endpoints, allowing clients to `create`, `read`, `update`, and `delete` items.

An item consists of
a `name`, provided by the client,
and an `id`, assigned by the API.

Items are uniquely identified by their `id`.

Creating or updating items is subject to `name` validation,
which must match the pattern `^[a-zA-Z]{5,30}$`.

Unlike a monolithic application,
CRUDify is designed to explore with a microservices architecture,
being composed of multiple resources:

- 4 `services` for the API.
- 4 `deployments` - one deployment for each API service.
- 1 `ingress` with 4 paths - one path for each API service.
- 1 `statefulset`, 1 `service`, and 1 `secret` for MongoDB to store the items.
- 4 `cronjobs` to simulate the clients - one client for each API service.
- 4 `servicemonitors` for Prometheus scraping - one service monitor for each API service.
- 1 `configmap` for Grafana dashboards.

API services:

- `item-creator`: Listens for client requests to `create` new items.
- `item-reader`: Listens for client requests to `read` items.
- `item-updater`: Listens for client requests to `update` items.
- `item-deleter`: Listens for client requests to `delete` items.

The API will be accessible at `http://crud.localhost/api`.

The ingress resource is configured to ensure that incoming traffic directed to `http://crud.localhost/api/<service>` is routed to the corresponding service.

When a service receives a client request via ingress routing,
it forwards the request to one of its target pods,
which perform the requested operation in the database,
generate relevant information in the logs,
update the application metrics,
and return a response to the client.



Four client applications simulate real users:

- `item-creator-client`
- `item-reader-client`
- `item-updater-client`
- `item-deleter-client`

These clients run as batch jobs on a cron schedule.
In each execution, they perform a random number of iterations.
For each iteration, they call the CRUDify API with random queries and data.
Some random-generated data may fail validation, leading to expected bad request errors.

#### Deploying CRUDify

We'll use the Argo CD `Application` resource.

This action requires the Argo CD application deployer credentials.

```bash
kubectl $(cat argocd-application-deployer.credentials) \
apply \
--namespace argocd \
--filename deploy/crudify/argocd-application.yaml
```

#### CRUDify synchronization

- http://argocd.localhost/applications/argocd/crudify?view=tree

```bash
argocd app wait crudify
```

#### CRUDify health check

Health check:

- http://crud.localhost/item-creator/healthz
- http://crud.localhost/item-reader/healthz
- http://crud.localhost/item-updater/healthz
- http://crud.localhost/item-deleter/healthz

```bash
urls="
http://crud.localhost/item-creator/healthz
http://crud.localhost/item-reader/healthz
http://crud.localhost/item-updater/healthz
http://crud.localhost/item-deleter/healthz
"
max_retries=3
retry_interval_seconds=10
for url in $urls; do
  retries=0
  until [ "$(curl -s -o /dev/null -w '%{http_code}' $url)" = "200" ]; do
    ((++retries));
    if [ $retries -ge $max_retries ]; then exit 1
    else sleep $retry_interval_seconds; fi
  done
done
```

#### Interacting with CRUDify's API

Clients interact with CRUDify's API via HTTP requests:

| Method   | URL                                        | Data               | Description |
| -------- | ------------------------------------------ | ------------------ | ----------- |
| `POST`   | `http://crud.localhost/api/create`         | `{ name: string }` | Creates a new item |
| `GET`    | `http://crud.localhost/api/read/<query>`   |                    | Retrieves items matching the query |
| `PUT`    | `http://crud.localhost/api/update/<query>` | `{ name: string }` | Updates items matching the query |
| `DELETE` | `http://crud.localhost/api/delete/<query>` |                    | Deletes items matching the query |

The `<query>` parameter is a regex used to filter items by name.

For example,
[`http://crud.localhost/item-reader/api/items/.*`](http://crud.localhost/item-reader/api/items/.*)
retrieves all items.

```bash
# Create item with name=FooBar
curl -X POST -H "Content-Type: application/json" -d '{"name":"FooBar"}' \
http://crud.localhost/item-creator/api/items

# Read items with name=FooBar
curl -X GET \
http://crud.localhost/item-reader/api/items/%5EFooBar%24

# Update items with name=FooBar to name=BarFoo
curl -X PUT -H "Content-Type: application/json" -d '{"name":"BarFoo"}' \
http://crud.localhost/item-updater/api/items/%5EFooBar%24

# Delete items with name=BarFoo
curl -X DELETE \
http://crud.localhost/item-deleter/api/items/%5EBarFoo%24
```

#### CRUDify database

CRUDify uses MongoDB to store the items.
The configuration includes a stateful-set for the MongoDB container.

#### CRUDify logs

CRUDify logs are directed to stdout and transiently stored in files on the cluster nodes.
These logs are then collected by Promtail agents and forwarded to the Loki server,
enabling easy visualization of logs through Grafana dashboards.

Logs for the last 30 minutes in the 'crudify' namespace:

- Grafana >> Explore >> Select datasource: `loki` >> Select label: `namespace` >> Select value: `crudify` >> Select range: `Last 30 minutes` >> Run query
- http://grafana.localhost/explore?schemaVersion=1&orgId=1&panes=%7B%22dHt%22%3A%7B%22datasource%22%3A%22loki%22%2C%22queries%22%3A%5B%7B%22refId%22%3A%22A%22%2C%22expr%22%3A%22%7Bnamespace%3D%5C%22crudify%5C%22%7D%20%7C%3D%20%60%60%22%2C%22queryType%22%3A%22range%22%2C%22datasource%22%3A%7B%22type%22%3A%22loki%22%2C%22uid%22%3A%22loki%22%7D%2C%22editorMode%22%3A%22builder%22%7D%5D%2C%22range%22%3A%7B%22from%22%3A%22now-30m%22%2C%22to%22%3A%22now%22%7D%7D%7D

#### CRUDify metrics

CRUDify services provide Prometheus metrics for monitoring and performance analysis.
Each service is equipped with its own service monitor,
instructing the Prometheus operator on the targets to scrape for metrics.
The metrics collected from these services can be visualized within Grafana dashboards.

Service monitor targets:
- Prometheus >> Status >> Targets >> Filter by endpoint or labels: `crudify`
- http://prometheus.localhost/targets?search=crudify

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

#### CRUDify dashboards

- http://grafana.localhost/d/crudify

<!-- END crudify -->
<!-- END deploy -->
<!-- END up -->
<!-- BEGIN down -->

## 7. Cleanup and Tear Down

This step involves deleting all resources in the cluster,
which includes undeploying applications, uninstalling cluster tools, and removing RBAC and namespace configurations.
Finally, the cluster itself is destroyed.

<!-- BEGIN undeploy -->

### Undeploying applications

```bash
# Undeploying Hello World
argocd appset delete hello-world --yes

# Undeploying CRUDify
argocd app delete crudify --yes
```

<!-- END undeploy -->

### Uninstalling cluster tools

```bash
terraform -chdir=cluster-tools/trivy-operator destroy $(cat cluster-tools-installer.credentials) -auto-approve
terraform -chdir=cluster-tools/argo-cd destroy $(cat cluster-tools-installer.credentials) -auto-approve
terraform -chdir=cluster-tools/kube-prometheus-stack destroy $(cat cluster-tools-installer.credentials) -auto-approve
terraform -chdir=cluster-tools/ingress-nginx destroy $(cat cluster-tools-installer.credentials) -auto-approve
terraform -chdir=cluster-tools/promtail destroy $(cat cluster-tools-installer.credentials) -auto-approve
terraform -chdir=cluster-tools/loki destroy $(cat cluster-tools-installer.credentials) -auto-approve
```

### Removing RBAC and namespace configurations

```bash
# Destroy namespace-configs
terraform -chdir=namespace-configs destroy $(cat namespace-manager.credentials) -auto-approve

# Destroy cluster-operators
terraform -chdir=cluster-operators destroy $(cat root-user.credentials) -auto-approve
```

<!-- BEGIN destroy -->

### Destroying cluster

```bash
# Destroy local-cluster
terraform -chdir=local-cluster destroy -auto-approve
```

### Forcibly destroying cluster

If for some reason previous cleanup actions failed,
or if you lost a Terraform state,
or even if you want a quick teardown,
this script ensures that all Docker containers used as cluster nodes are stopped and deleted.

```bash
docker ps -a --format "{{.Names}}" | grep "^k8slab-" | while read -r container_name; do
  docker stop "$container_name" >/dev/null 2>&1
  docker rm "$container_name" >/dev/null 2>&1
done
```

### Removing gitignored files

```bash
(cd cluster-tools;     git clean -Xfd)
(cd namespace-configs; git clean -Xfd)
(cd cluster-operators; git clean -Xfd)
(cd local-cluster;     git clean -Xfd)

git clean -Xf
```

<!-- END destroy -->
<!-- END down -->
