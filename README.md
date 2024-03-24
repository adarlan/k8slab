# K8sLab

A project intended for exploring with a local [Kubernetes](https://kubernetes.io/) cluster
bundled with popular open-source tools and example applications,
simulating a real environment.

Use [Terraform](https://www.terraform.io/) to set up a [KinD](https://kind.sigs.k8s.io/) (Kubernetes-in-Docker) cluster,
applying Role-Based Access Control (RBAC) configurations,
enforcing resource quotas, and defining limit ranges.
Additionally, enhance the cluster's capabilities by installing tools such as
[Ingress-Nginx](https://kubernetes.github.io/ingress-nginx/) for traffic routing,
[Argo CD](https://argoproj.github.io/cd/) for continuous deployment,
[Prometheus](https://prometheus.io/) for metrics scraping,
[Loki](https://grafana.com/oss/loki/) for log aggregation,
and [Grafana](https://grafana.com/oss/grafana/) for dashboard visualization.

Deploy a pair of example applications across multiple environments,
interact with their exposed endpoints,
and delve into meaningful logs, metrics, and dashboards.
Finally, interact with the cluster utilizing dummy user credentials
to impersonate both application developers and cluster operators.

Run the simulation by following these steps:

1. [Cluster Provisioning](#1-cluster-provisioning) - Creating a local Kubernetes cluster.
2. [Cluster-Level RBAC Configuration](#2-cluster-level-rbac-configuration) - Granting access to cluster-wide users and service accounts.
3. [Namespace Provisioning](#3-namespace-provisioning) - Creating namespaces along with their resource quotas and limit ranges.
4. [Namespace-Level RBAC Configuration](#4-namespace-level-rbac-configuration) - Granting namespace-level access for users and service accounts.
5. [Cluster Toolkit Installation](#5-cluster-toolkit-installation) - Installing tools that extend the cluster's functionality.
6. [Application Deployment](#6-application-deployment) - Deploying example applications to the cluster.

Use the [`run.sh`](./run.sh) script to run the simulation automatically:

- `./run.sh up` to run all steps, from cluster provisioning to application deployment.
- `./run.sh down` to remove all resources and destroy the cluster.

The following CLI tools are required for setting up and interacting with your local Kubernetes environment:

- [`terraform`](https://www.terraform.io/) for resource provisioning.
- [`docker`](https://docs.docker.com/engine/) (Docker Engine) for running cluster "nodes".
- [`kubectl`](https://kubernetes.io/docs/reference/kubectl/) for interacting with the cluster.
- [`argocd`](https://argo-cd.readthedocs.io/en/stable/cli_installation/) for deployment management.
- [`helm`](https://helm.sh/) for manifest file generation.
- [`kustomize`](https://kustomize.io/) (built into `kubectl`) for simplified manifest configuration.

<!-- COMMAND up -->
## Simulation Run

<!-- COMMAND apply cluster-provisioning -->
### 1. Cluster Provisioning

This action creates a KinD cluster,
which is a local Kubernetes cluster that uses Docker containers as "nodes".

We could use the `kind` CLI tool to create the cluster,
but we will use `terraform` to make it more like a real environment.

The cluster has one control-plane node and two worker nodes.

The control-plane node has ports `80` and `443` mapped to localhost
for the ingress controller to expose application endpoints.

```bash
terraform -chdir=cluster-provisioning init
terraform -chdir=cluster-provisioning apply -auto-approve
```

Setting cluster entry in kubeconfig for users to interact with the cluster:

```bash
kubectl config set-cluster k8slab --server $(cat cluster-endpoint.txt) --certificate-authority cluster-ca.crt
```

Setting root user credentials into kubeconfig to interact with the cluster:

```bash
kubectl config set-credentials k8slab-root --client-key root.key --client-certificate root.crt
kubectl config set-context k8slab-root --cluster=k8slab --user=k8slab-root

kubectl config use-context k8slab-root
kubectl auth whoami
kubectl auth can-i --list
```

<!-- COMMAND apply cluster-rbac -->
### 2. Cluster-Level RBAC Configuration

This action grants access to cluster-wide users and service accounts.
It includes granting cluster operator access for a user called Jane Ops,
as well as establishing the service accounts responsible for subsequent cluster configurations, such as namespace provisioning, namespace-level RBAC configuration, and cluster toolkit installation.

```bash
terraform -chdir=cluster-rbac init

terraform -chdir=cluster-rbac apply -auto-approve \
-var cluster_endpoint=$(cat cluster-endpoint.txt) \
-var cluster_ca_certificate=$(realpath cluster-ca.crt) \
-var root_user_key=$(realpath root.key) \
-var root_user_certificate=$(realpath root.crt)
```

Jane Ops credentials:

```bash
openssl genrsa -out janeops.key 2048
openssl req -new -key janeops.key -out janeops.csr -subj "/CN=Jane Ops"
openssl x509 -req -in janeops.csr -CA cluster-ca.crt -CAkey cluster-ca.key -CAcreateserial -out janeops.crt -days 1

kubectl config set-credentials janeops --client-key janeops.key --client-certificate janeops.crt
kubectl config set-context janeops --cluster k8slab --user janeops

kubectl config use-context janeops
kubectl auth whoami
kubectl auth can-i --list
```

<!-- COMMAND apply namespace-provisioning -->
### 3. Namespace Provisioning

This action creates the namespaces that will host applications, enforcing resource quotas and limit ranges.

```bash
terraform -chdir=namespace-provisioning init

terraform -chdir=namespace-provisioning apply -auto-approve \
-var cluster_endpoint=$(cat cluster-endpoint.txt) \
-var cluster_ca_certificate=$(realpath cluster-ca.crt) \
-var namespace_provisioning_token=$(realpath namespace-provisioning.token)
```

<!-- COMMAND apply namespace-rbac -->
### 4. Namespace-Level RBAC Configuration

This action grants namespace-level access for users and service accounts.
It includes granting developer access for a user calles John Dev,
as well as establishing the service account responsible for application deployment.

```bash
terraform -chdir=namespace-rbac init

terraform -chdir=namespace-rbac apply -auto-approve \
-var cluster_endpoint=$(cat cluster-endpoint.txt) \
-var cluster_ca_certificate=$(realpath cluster-ca.crt) \
-var namespace_rbac_token=$(realpath namespace-rbac.token)
```

John Dev credentials:

```bash
openssl genrsa -out johndev.key 2048
openssl req -new -key johndev.key -out johndev.csr -subj "/CN=John Dev"
openssl x509 -req -in johndev.csr -CA cluster-ca.crt -CAkey cluster-ca.key -CAcreateserial -out johndev.crt -days 1

kubectl config set-credentials johndev --client-key johndev.key --client-certificate johndev.crt
kubectl config set-context johndev --user johndev --cluster k8slab --namespace development

kubectl --context johndev auth whoami
kubectl --context johndev auth can-i --list
```

<!-- COMMAND install cluster-toolkit -->
### 5. Cluster Toolkit Installation

This action install tools that extend the cluster's capabilities in terms of networking, deployment, and monitoring.

<!-- COMMAND install cluster-toolkit ingress -->
#### Ingress-Nginx Controller

The ingress controller is configured using `localhost` to emulate a live domain.

```bash
terraform -chdir=cluster-toolkit/ingress init

terraform -chdir=cluster-toolkit/ingress apply -auto-approve \
-var cluster_endpoint=$(cat cluster-endpoint.txt) \
-var cluster_ca_certificate=$(realpath cluster-ca.crt) \
-var cluster_toolkit_token=$(realpath cluster-toolkit.token)
```

<!-- COMMAND install cluster-toolkit argocd -->
#### Argo CD

```bash
terraform -chdir=cluster-toolkit/argocd init

terraform -chdir=cluster-toolkit/argocd apply -auto-approve \
-var cluster_endpoint=$(cat cluster-endpoint.txt) \
-var cluster_ca_certificate=$(realpath cluster-ca.crt) \
-var cluster_toolkit_token=$(realpath cluster-toolkit.token)
```

```bash
kubectl config set-credentials k8slab-argocd-application-deployer --token $(cat argocd-application-deployer.token)
kubectl config set-context k8slab-argocd-application-deployer --cluster k8slab --user k8slab-argocd-application-deployer --namespace argocd
```

Argo CD CLI login:

```bash
argocd login --grpc-web --insecure argocd.localhost --username admin --password $(cat argocd-admin.password)
```

Argo CD user interface:

- [http://argocd.localhost](http://argocd.localhost)
- Username: `admin`
- The password is stored in the file: `argocd-admin.password`
<!-- EXEC nohup xdg-open http://argocd.localhost > /dev/null 2>&1 -->

<!-- COMMAND install cluster-toolkit monitoring -->
#### Monitoring Stack

```bash
sudo sysctl -w fs.inotify.max_user_instances=256
```

```bash
terraform -chdir=cluster-toolkit/monitoring init

terraform -chdir=cluster-toolkit/monitoring apply -auto-approve \
-var cluster_endpoint=$(cat cluster-endpoint.txt) \
-var cluster_ca_certificate=$(realpath cluster-ca.crt) \
-var cluster_toolkit_token=$(realpath cluster-toolkit.token)
```

Prometheus user interface:

- [http://prometheus.localhost](http://prometheus.localhost)
<!-- EXEC nohup xdg-open http://prometheus.localhost > /dev/null 2>&1 -->

Grafana user interface:

- [http://grafana.localhost](http://grafana.localhost)
- Username: `admin`
- The password is stored in the file: `grafana-admin.password`
<!-- EXEC nohup xdg-open http://grafana.localhost > /dev/null 2>&1 -->

<!-- COMMAND app-deploy -->
### 6. Application Deployment

To explore with the cluster features, we will deploy two example applications:

- [Hello World](#hello-world): A simple web application that will be deployed across multiple environments with distinct configuration.
- [CRUDify](#crudify): A microservice-based CRUD application designed to experiment with meaningful metrics, logs, dashboards, and other features.

The source code of the applications reside in the [`app-code`](./app-code/) directory:

- [`app-code/hello-world`](./app-code/hello-world/)
- [`app-code/crudify`](./app-code/crudify/)

GitHub Actions watches for changes in these directories
to test, build and push the Docker images to Docker Hub.

The deployment configuration of the applications reside in the [`app-deploy`](./app-deploy/) directory.

- [`app-deploy/hello-world`](./app-deploy/hello-world/)
- [`app-deploy/crudify`](./app-deploy/crudify/)

Argo CD watches for changes in these directories
to deploy and synchronize modifications into the cluster.

<!-- COMMAND app-deploy hello-world -->
#### Hello World

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

##### Hello World Deployment

```bash
kubectl --context k8slab-argocd-application-deployer \
apply --filename app-deploy/hello-world/argocd-application-set.yaml
```

##### Hello World Synchronization

```bash
argocd app wait --selector appset=hello-world
```

##### Hello World Health Check

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

##### Hello World User Interface

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

<!-- COMMAND app-deploy crudify -->
#### CRUDify

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

##### CRUDify Deployment

We'll use the Argo CD `Application` resource to deploy the CRUDify application.

```bash
kubectl --context k8slab-argocd-application-deployer \
apply --filename app-deploy/crudify/argocd-application.yaml
```

##### CRUDify Synchronization

- http://argocd.localhost/applications/argocd/crudify?view=tree

```bash
argocd app wait crudify
```

##### CRUDify Health Check

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

##### CRUDify API

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

##### CRUDify Logs

The logs are directed to stdout and transiently stored in files on the cluster nodes.
These logs are then collected by Promtail agents and forwarded to the Loki server,
enabling easy visualization of logs through Grafana dashboards.

Logs for the last 30 minutes:

- Grafana >> Explore >> Select datasource: `loki` >> Select label: `namespace` >> Select value: `crudify` >> Select range: `Last 30 minutes` >> Run query
- http://grafana.localhost/explore?schemaVersion=1&orgId=1&panes=%7B%22dHt%22%3A%7B%22datasource%22%3A%22loki%22%2C%22queries%22%3A%5B%7B%22refId%22%3A%22A%22%2C%22expr%22%3A%22%7Bnamespace%3D%5C%22crudify%5C%22%7D%20%7C%3D%20%60%60%22%2C%22queryType%22%3A%22range%22%2C%22datasource%22%3A%7B%22type%22%3A%22loki%22%2C%22uid%22%3A%22loki%22%7D%2C%22editorMode%22%3A%22builder%22%7D%5D%2C%22range%22%3A%7B%22from%22%3A%22now-30m%22%2C%22to%22%3A%22now%22%7D%7D%7D

##### CRUDify Metrics

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

##### CRUDify Dashboards

- http://grafana.localhost/d/crudify

<!-- COMMAND down -->
## 7. Simulation Terminate

This step involves deleting all resources in the cluster,
which includes undeploying applications, uninstalling cluster toolkit, and removing RBAC and namespace configurations.
Finally, the cluster itself is destroyed.

<!-- COMMAND undeploy hello-world -->
### Undeploy Hello World Application

```bash
argocd appset delete hello-world --yes
```

<!-- COMMAND undeploy crudify -->
### Undeploy CRUDify Application

```bash
argocd app delete crudify --yes
```

<!-- COMMAND uninstall monitoring -->
### Uninstall Monitoring Toolkit

```bash
terraform -chdir=cluster-toolkit/monitoring destroy -auto-approve \
-var cluster_endpoint=$(cat cluster-endpoint.txt) \
-var cluster_ca_certificate=$(realpath cluster-ca.crt) \
-var cluster_toolkit_token=$(realpath cluster-toolkit.token)
```

<!-- COMMAND uninstall argocd -->
### Uninstall ArgoCD Toolkit

```bash
terraform -chdir=cluster-toolkit/argocd destroy -auto-approve \
-var cluster_endpoint=$(cat cluster-endpoint.txt) \
-var cluster_ca_certificate=$(realpath cluster-ca.crt) \
-var cluster_toolkit_token=$(realpath cluster-toolkit.token)
```

<!-- COMMAND uninstall ingress -->
### Uninstall Ingress Toolkit

```bash
terraform -chdir=cluster-toolkit/ingress destroy -auto-approve \
-var cluster_endpoint=$(cat cluster-endpoint.txt) \
-var cluster_ca_certificate=$(realpath cluster-ca.crt) \
-var cluster_toolkit_token=$(realpath cluster-toolkit.token)
```

<!-- COMMAND remove namespace-rbac -->
### Remove Namespace RBAC Configuration

```bash
terraform -chdir=namespace-rbac destroy -auto-approve \
-var cluster_endpoint=$(cat cluster-endpoint.txt) \
-var cluster_ca_certificate=$(realpath cluster-ca.crt) \
-var namespace_rbac_token=$(realpath namespace-rbac.token)
```

<!-- COMMAND remove namespace-provisioning -->
### Remove Namespace Provisioning

```bash
# terraform -chdir=namespace-provisioning destroy -auto-approve \
# -var cluster_endpoint=$(cat cluster-endpoint.txt) \
# -var cluster_ca_certificate=$(realpath cluster-ca.crt) \
# -var namespace_provisioning_token=$(realpath namespace-provisioning.token)
```

<!-- COMMAND remove cluster-rbac -->
### Remove Cluster RBAC Configuration

```bash
terraform -chdir=cluster-rbac destroy -auto-approve \
-var cluster_endpoint=$(cat cluster-endpoint.txt) \
-var cluster_ca_certificate=$(realpath cluster-ca.crt) \
-var root_user_key=$(realpath root.key) \
-var root_user_certificate=$(realpath root.crt)
```

<!-- COMMAND destroy cluster -->
### Destroy Cluster

```bash
terraform -chdir=cluster-provisioning destroy -auto-approve
```

<!-- COMMAND clean -->
### Clean

<!-- COMMAND clean nodes -->
#### Delete Cluster Nodes

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

<!-- COMMAND clean files -->
#### Removing gitignored files

```bash
git clean -Xf
```
