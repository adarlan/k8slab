# K8sLab

A project intended for exploring with a local [Kubernetes](https://kubernetes.io/) cluster
bundled with popular open-source tools and example applications,
simulating a real environment.

### Features

- [Terraform](https://www.terraform.io/) for resource provisioning
- [Helm](https://helm.sh/) for manifest file generation
- [Kustomize](https://kustomize.io/) for deployment configuration
- [Argo CD](https://argoproj.github.io/cd/) for continuous deployment
- [Ingress-Nginx Controller](https://kubernetes.github.io/ingress-nginx/) for traffic routing
- [Prometheus](https://prometheus.io/) for metrics scraping
- [Grafana Loki](https://grafana.com/oss/loki/) for log aggregation
- [Grafana OSS](https://grafana.com/oss/grafana/) for dashboard visualization

### Example Applications

To explore with the cluster features, we will deploy two example applications:

- [Hello World](#hello-world): A simple web application that displays a greeting message and will be continuously deployed across multiple environments with distinct configuration.
- [CRUDify](#crudify): A microservice-based CRUD application composed by multiple components designed to experiment with metrics, logs, dashboards, and other features.

### Simulation Steps

Run the simulation by following the step-by-step guide below.

1. [Cluster Provisioning](#1-cluster-provisioning)
2. [Cluster-Level RBAC](#2-cluster-level-rbac)
3. [Namespace Provisioning](#3-namespace-provisioning)
4. [Namespace-Level RBAC](#4-namespace-level-rbac)
5. [Cluster Toolkit Installation](#5-cluster-toolkit-installation)
6. [Application Deployment](#6-application-deployment)

To execute these steps automatically, use the [`run.sh`](./run.sh) script:

- `./run.sh up` to run all steps from cluster provisioning to application deployment.
- `./run.sh down` to remove resources and destroy the cluster.

Requirements:

- Docker Engine
- Terraform
- Kubernetes CLI (`kubectl`)
- Argo CD CLI (`argocd`)

<!-- BEGIN up -->
<!-- BEGIN cluster-provisioning -->

## 1. Cluster Provisioning

This step involves creating the Kubernetes cluster itself.

We'll create a [KinD](https://kind.sigs.k8s.io/) (Kubernetes-in-Docker) cluster,
which is a local Kubernetes cluster that uses Docker containers as "nodes".

We could use the `kind` CLI tool to create the cluster,
but we will use `terraform` to make it more like a real environment.

The Terraform configuration is defined in the [`cluster-provisioning`](./cluster-provisioning) directory.

```bash
# Init and apply cluster-provisioning Terraform configuration
terraform -chdir=cluster-provisioning init
terraform -chdir=cluster-provisioning apply -auto-approve
```

### Cluster credentials

These credentials are necessary for users and service accounts to connect to the cluster.

```bash
# Retrieve cluster endpoint
terraform -chdir=cluster-provisioning output -raw endpoint > cluster-endpoint.txt

# Retrieve cluster CA certificate
terraform -chdir=cluster-provisioning output -raw ca_certificate > cluster-ca.crt

# Set cluster entry in kubeconfig
kubectl config set-cluster k8slab --server=$(cat cluster-endpoint.txt) --certificate-authority=$(realpath cluster-ca.crt) --embed-certs=true
```

We'll need the cluster CA key to sign user certificates.

```bash
# Retrieve cluster CA key
terraform -chdir=cluster-provisioning output -raw ca_key > cluster-ca.key
```

### Root user credentials

```bash
# Retrieve root user key
terraform -chdir=cluster-provisioning output -raw root_user_key > root.key

# Retrieve root user certificate
terraform -chdir=cluster-provisioning output -raw root_user_certificate > root.crt

# Create root-user.credentials file
echo \
-var cluster_endpoint=$(cat cluster-endpoint.txt) \
-var cluster_ca_certificate=$(realpath cluster-ca.crt) \
-var root_user_key=$(realpath root.key) \
-var root_user_certificate=$(realpath root.crt) \
> root-user.credentials
```

<!-- END cluster-provisioning -->
<!-- BEGIN cluster-rbac -->

## 2. Cluster-Level RBAC

This step involves granting access to cluster-wide users and service accounts that will be given cluster roles.

This action will create:

- the `namespace-provisioning` service account,
- the `namespace-rbac` service account,
- the `cluster-toolkit` service account,
- and the `cluster-administrator` cluster role along with a `Jane Ops` user cluster role binding.

You can change this configuration by editing the [`cluster-rbac/values.yaml`](./cluster-rbac/values.yaml) file.

This is the only action that requires the `root-user` credentials.
After this, we'll have less-privileged users and service accounts to operate the cluster.

```bash
# Init and apply cluster-rbac Terraform configuration
terraform -chdir=cluster-rbac init
terraform -chdir=cluster-rbac apply $(cat root-user.credentials) -auto-approve
```

### Namespace Provisioning Credentials

These credentials are necessary for provisioning namespaces along with their resource quotas and limit ranges.

```bash
# Retrieve namespace-provisioning service account token
terraform -chdir=cluster-rbac output -raw namespace_provisioning_token > namespace-provisioning.token

# Create namespace-provisioning.credentials file
echo \
-var cluster_endpoint=$(cat cluster-endpoint.txt) \
-var cluster_ca_certificate=$(realpath cluster-ca.crt) \
-var namespace_provisioning_token=$(realpath namespace-provisioning.token) \
> namespace-provisioning.credentials
```

### Namespace RBAC Credentials

These credentials are necessary for granting namespace-level access for users and service accounts.

```bash
# Retrieve namespace-rbac service account token
terraform -chdir=cluster-rbac output -raw namespace_rbac_token > namespace-rbac.token

# Create namespace-rbac.credentials file
echo \
-var cluster_endpoint=$(cat cluster-endpoint.txt) \
-var cluster_ca_certificate=$(realpath cluster-ca.crt) \
-var namespace_rbac_token=$(realpath namespace-rbac.token) \
> namespace-rbac.credentials
```

### Cluster Toolkit Credentials

These credentials are necessary for installing tools that extend the cluster's functionality.

```bash
# Retrieve cluster-toolkit service account token
terraform -chdir=cluster-rbac output -raw cluster_toolkit_token > cluster-toolkit.token

# Create cluster-toolkit.credentials file
echo \
-var cluster_endpoint=$(cat cluster-endpoint.txt) \
-var cluster_ca_certificate=$(realpath cluster-ca.crt) \
-var cluster_toolkit_token=$(realpath cluster-toolkit.token) \
> cluster-toolkit.credentials
```

### Jane Ops Credentials

Jane Ops is a cluster-wide user responsible for administrating the cluster.

To facilitate your interaction with the cluster,
we will set up Jane Ops credentials in your `kubectl` configuration.

To use her credentials,
simply run `kubectl config use-context janeops` before your `kubectl` commands
or add the `--context janeops` option to each `kubectl` command.

```bash
# Generate private key
openssl genrsa -out janeops.key 2048

# Generate Certificate Signing Request (CSR) file
openssl req -new -key janeops.key -out janeops.csr -subj "/CN=Jane Ops"

# Sign certificate
openssl x509 -req -in janeops.csr -CA cluster-ca.crt -CAkey cluster-ca.key -CAcreateserial -out janeops.crt -days 1

# Set user entry in kubeconfig
kubectl config set-credentials janeops --client-key=janeops.key --client-certificate=janeops.crt --embed-certs=true

# Set context entry in kubeconfig
kubectl config set-context janeops --cluster=k8slab --user=janeops
```

<!-- END cluster-rbac -->
<!-- BEGIN namespace-provisioning -->

## 3. Namespace Provisioning

This step involves creating `namespaces` along with their `resourcequotas` and `limitranges`.

Namespaces to host the cluster toolkit:

- `argocd`
- `ingress`
- `monitoring`

Namespaces to host the Hello World application:

- `development`
- `staging`
- `production`

Namespaces to host the CRUDify application:

- `crudify-api`
- `crudify-database`
- `crudify-clients`

You can change this configuration by editing the [`namespace-provisioning/values.yaml`](./namespace-provisioning/values.yaml) file.

This action requires the `namespace-provisioning` credentials.

```bash
# Init and apply namespace-provisioning configuration
terraform -chdir=namespace-provisioning init
terraform -chdir=namespace-provisioning apply $(cat namespace-provisioning.credentials) -auto-approve
```

<!-- END namespace-provisioning -->
<!-- BEGIN namespace-rbac -->

## 4. Namespace-Level RBAC

This step involves granting namespace-level access for users and service accounts.

It will create:

- The `application-deployer` service account in the `argocd` namespace
- The `developer` role along with a `John Dev` user role binding in the `development` namespace

You can change this configuration by editing the [`namespace-rbac/values.yaml`](./namespace-rbac/values.yaml) file.

This action requires the `namespace-rbac` credentials.

```bash
# Init and apply namespace-rbac Terraform configuration
terraform -chdir=namespace-rbac init
terraform -chdir=namespace-rbac apply $(cat namespace-rbac.credentials) -auto-approve
```

### Argo CD application deployer credentials

Argo CD application deployer is a namespace-level service account
responsible for managing the `Application` and `ApplicationSet` resources in the `argocd` namespace.

```bash
# Retrieve the argocd-application-deployer service account token
terraform -chdir=namespace-rbac output -raw argocd_application_deployer_token > argocd-application-deployer.token

# Create the argocd-application-deployer.credentials file
echo \
--server=$(cat cluster-endpoint.txt) \
--certificate-authority=$(realpath cluster-ca.crt) \
--token=$(cat argocd-application-deployer.token) \
> argocd-application-deployer.credentials
```

### John Dev credentials

John Dev is a namespace-level user responsible for developing applications,
authorized to manage application resources in the `development` namespace.

To facilitate your interaction with the cluster,
we will set up John Dev credentials in your `kubectl` configuration.

To use his credentials,
simply run `kubectl config use-context johndev` before your `kubectl` commands
or add the `--context johndev` option to each `kubectl` command.

```bash
# Generate private key
openssl genrsa -out johndev.key 2048

# Generate Certificate Signing Request (CSR) file
openssl req -new -key johndev.key -out johndev.csr -subj "/CN=John Dev"

# Sign certificate
openssl x509 -req -in johndev.csr -CA cluster-ca.crt -CAkey cluster-ca.key -CAcreateserial -out johndev.crt -days 1

# Set user entry in kubeconfig
kubectl config set-credentials johndev --client-key=johndev.key --client-certificate=johndev.crt --embed-certs=true

# Set context entry in kubeconfig
kubectl config set-context johndev --cluster=k8slab --user=johndev
```

<!-- END namespace-rbac -->
<!-- BEGIN cluster-toolkit -->

## 5. Cluster Toolkit Installation

This step involves installing tools that extend the functionality of the Kubernetes cluster,
improving networking, deployment, monitoring, and more.

The configuration is defined in the [`cluster-toolkit`](./cluster-toolkit) directory.

This action requires the `cluster-toolkit` credentials.

### Installing Nginx Ingress Controller

```bash
name=ingress-nginx
terraform -chdir=cluster-toolkit/$name init
terraform -chdir=cluster-toolkit/$name apply $(cat cluster-toolkit.credentials) -auto-approve
```

### Installing Argo CD

```bash
name=argo-cd
terraform -chdir=cluster-toolkit/$name init
terraform -chdir=cluster-toolkit/$name apply $(cat cluster-toolkit.credentials) -auto-approve
```

#### Argo CD admin password

```bash
terraform -chdir=cluster-toolkit/argo-cd output -raw admin_password > argocd-admin.password
```

#### Argo CD CLI login

```bash
argocd login --grpc-web --insecure argocd.localhost --username admin --password $(cat argocd-admin.password)
```

#### Argo CD user interface

- [http://argocd.localhost](http://argocd.localhost)
- Username: `admin`
- The password is stored in the file: `argocd-admin.password`

<!-- COMMAND nohup xdg-open http://argocd.localhost > /dev/null 2>&1 -->
<!-- COMMAND echo Username: admin -->
<!-- COMMAND echo Password: $(cat argocd-admin.password) -->

### Installing Grafana Loki

```bash
name=loki
terraform -chdir=cluster-toolkit/$name init
terraform -chdir=cluster-toolkit/$name apply $(cat cluster-toolkit.credentials) -auto-approve
```

### Installing Promtail Agent

```bash
name=promtail
terraform -chdir=cluster-toolkit/$name init
terraform -chdir=cluster-toolkit/$name apply $(cat cluster-toolkit.credentials) -auto-approve
```

### Installing Kube Prometheus Stack

```bash
name=kube-prometheus-stack
terraform -chdir=cluster-toolkit/$name init
terraform -chdir=cluster-toolkit/$name apply $(cat cluster-toolkit.credentials) -auto-approve
```

#### Prometheus user interface

- [http://prometheus.localhost](http://prometheus.localhost)

<!-- COMMAND nohup xdg-open http://prometheus.localhost > /dev/null 2>&1 -->

#### Grafana admin password

```bash
terraform -chdir=cluster-toolkit/kube-prometheus-stack output -raw grafana_admin_password > grafana-admin.password
```

#### Grafana user interface

- [http://grafana.localhost](http://grafana.localhost)
- Username: `admin`
- The password is stored in the file: `grafana-admin.password`

<!-- COMMAND nohup xdg-open http://grafana.localhost > /dev/null 2>&1 -->
<!-- COMMAND echo Username: admin -->
<!-- COMMAND echo Password: $(cat grafana-admin.password) -->

<!-- END cluster-toolkit -->
<!-- BEGIN deploy -->

## 6. Application Deployment

This step involves deploying example applications into the Kubernetes cluster.

#### Application source code

The source code of the applications reside in the [`app-code`](./app-code/) directory:

- [`app-code/hello-world`](./app-code/hello-world/)
- [`app-code/crudify`](./app-code/crudify/)

GitHub Actions watches for changes in these directories
to test, build and push the Docker images to Docker Hub.

#### Application deployment configuration

The deployment configuration of the applications reside in the [`app-deploy`](./app-deploy/) directory.

- [`app-deploy/hello-world`](./app-deploy/hello-world/)
- [`app-deploy/crudify`](./app-deploy/crudify/)

Argo CD watches for changes in these directories
to deploy and synchronize modifications into the cluster.

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
[`app-deploy/hello-world/argocd-application-set.yaml`](./app-deploy/hello-world/argocd-application-set.yaml)
file.

#### Hello World Deployment

This action requires the Argo CD application deployer credentials.

```bash
kubectl $(cat argocd-application-deployer.credentials) \
apply \
--namespace argocd \
--filename app-deploy/hello-world/argocd-application-set.yaml
```

#### Hello World Synchronization

```bash
argocd app wait --selector appset=hello-world
```

#### Hello World Health Check

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

#### Hello World User Interface

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

The API exposes four endpoints,
allowing clients to `create`, `read`, `update`, and `delete` items.

An item consists of
a `name`, provided by the client,
and an `id`, assigned by the API.

Items are uniquely identified by their `id`.

Creating or updating items is subject to `name` validation,
which must match the pattern `^[a-zA-Z]{5,30}$`.

CRUDify uses MongoDB to store the items.

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

#### CRUDify Deployment

We'll use the Argo CD `Application` resource to deploy the CRUDify application.

This action requires the `argocd-application-deployer` credentials.

```bash
kubectl $(cat argocd-application-deployer.credentials) \
apply \
--namespace argocd \
--filename app-deploy/crudify/argocd-application.yaml
```

#### CRUDify Synchronization

- http://argocd.localhost/applications/argocd/crudify?view=tree

```bash
argocd app wait crudify
```

#### CRUDify Health Check

Each API service exposes a `/healthz` endpoint:

- http://crud.localhost/item-creator/healthz
- http://crud.localhost/item-reader/healthz
- http://crud.localhost/item-updater/healthz
- http://crud.localhost/item-deleter/healthz

Let's await the return of a `200` HTTP status code from these endpoints.

```bash
urls="http://crud.localhost/item-creator/healthz
http://crud.localhost/item-reader/healthz
http://crud.localhost/item-updater/healthz
http://crud.localhost/item-deleter/healthz"
for url in $urls; do
  retries=0
  until [ "$(curl -s -o /dev/null -w '%{http_code}' $url)" = "200" ]; do
    ((++retries));
    if [ $retries -ge 3 ]; then exit 1
    else sleep 10; fi
  done
done
```

#### CRUDify API

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

You can interact with the API using `curl`:

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

#### CRUDify Logs

The logs are directed to stdout and transiently stored in files on the cluster nodes.
These logs are then collected by Promtail agents and forwarded to the Loki server,
enabling easy visualization of logs through Grafana dashboards.

Logs for the last 30 minutes:

- Grafana >> Explore >> Select datasource: `loki` >> Select label: `namespace` >> Select value: `crudify` >> Select range: `Last 30 minutes` >> Run query
- http://grafana.localhost/explore?schemaVersion=1&orgId=1&panes=%7B%22dHt%22%3A%7B%22datasource%22%3A%22loki%22%2C%22queries%22%3A%5B%7B%22refId%22%3A%22A%22%2C%22expr%22%3A%22%7Bnamespace%3D%5C%22crudify%5C%22%7D%20%7C%3D%20%60%60%22%2C%22queryType%22%3A%22range%22%2C%22datasource%22%3A%7B%22type%22%3A%22loki%22%2C%22uid%22%3A%22loki%22%7D%2C%22editorMode%22%3A%22builder%22%7D%5D%2C%22range%22%3A%7B%22from%22%3A%22now-30m%22%2C%22to%22%3A%22now%22%7D%7D%7D

#### CRUDify Metrics

The API services are instrumented to provide Prometheus metrics.
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

#### CRUDify Dashboards

- http://grafana.localhost/d/crudify

<!-- END crudify -->
<!-- END deploy -->
<!-- END up -->

<!-- BEGIN down -->

## 7. Cleanup and Tear Down

This step involves deleting all resources in the cluster,
which includes undeploying applications, uninstalling cluster toolkit, and removing RBAC and namespace configurations.
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

### Uninstalling cluster toolkit

```bash
terraform -chdir=cluster-toolkit/argo-cd destroy $(cat cluster-toolkit.credentials) -auto-approve
terraform -chdir=cluster-toolkit/kube-prometheus-stack destroy $(cat cluster-toolkit.credentials) -auto-approve
terraform -chdir=cluster-toolkit/ingress-nginx destroy $(cat cluster-toolkit.credentials) -auto-approve
terraform -chdir=cluster-toolkit/promtail destroy $(cat cluster-toolkit.credentials) -auto-approve
terraform -chdir=cluster-toolkit/loki destroy $(cat cluster-toolkit.credentials) -auto-approve
```

### Removing RBAC and namespace configurations

```bash
# Destroy namespace-rbac
terraform -chdir=namespace-rbac destroy $(cat namespace-rbac.credentials) -auto-approve

# Destroy namespace-provisioning
terraform -chdir=namespace-provisioning destroy $(cat namespace-provisioning.credentials) -auto-approve

# Destroy cluster-rbac
terraform -chdir=cluster-rbac destroy $(cat root-user.credentials) -auto-approve
```

<!-- BEGIN destroy -->

### Destroying cluster

```bash
# Destroy cluster-provisioning
terraform -chdir=cluster-provisioning destroy -auto-approve
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
(cd cluster-toolkit;          git clean -Xfd)
(cd namespace-rbac;         git clean -Xfd)
(cd namespace-provisioning; git clean -Xfd)
(cd cluster-rbac;           git clean -Xfd)
(cd cluster-provisioning;   git clean -Xfd)

git clean -Xf
```

<!-- END destroy -->
<!-- END down -->
