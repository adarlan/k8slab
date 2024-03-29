# TODO

## terraform helm_release

Dont use values.yaml.
Instead, use a terraform.tfvars file.
Because:
- Some terraform resources should be generated dinamically
- If you ubdate the values.yaml file, Terraform does not detect tha change (not sure of this)

## limit-ranges

## trivy

Installing Trivy Operator:

```bash
name=trivy-operator
terraform -chdir=cluster-toolkit/$name init
terraform -chdir=cluster-toolkit/$name apply $(cat cluster-toolkit.credentials) -auto-approve
```

## run.sh

<!-- IFNOT kubectl --context johndev auth whoami -->

## cluster-toolkit

Watch pods:
- `watch -n 1 kubectl --context janeops get pods --namespace ingress`

Watch pods:
- `watch -n 1 kubectl --context janeops get pods --namespace argocd`

Watch pods:
- `watch -n 1 kubectl --context janeops get pods --namespace monitoring`

Watch pods:
- `watch -n 1 kubectl --context janeops get pods --namespace trivy`

## rbac

the app deployer does not need permission to delete app and appset resources,
because its responsibility is just deploying.
deleting is responsibility of argocd operators (Peter Argoman?)

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

## asdf

The CLI tool versions are explicit in the [`.tool-versions`](./.tool-versions) file.

```bash
while IFS= read -r tool_version; do
  asdf plugin add $(echo $tool_version | awk '{print $1}')
  asdf install $tool_version
done < .tool-versions
```

## hello-world

- Use Kustomize instead of Helm for the deployment configuration

## Setting the maximum number of file system notification subscribers

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

promtail error:
level=error 
caller=main.go:170 
msg="error creating promtail" 
error="failed to make file target manager: too many open files"

loki-logs error:
caller=main.go:74 
level=error 
msg="error creating the agent server entrypoint" 
err="unable to apply config for monitoring/monitoring-stack-loki: unable to create logs instance: failed to make file target manager: too many open files"

https://maestral.app/docs/inotify-limits

## trivy-operator

You have installed Trivy Operator in the trivy namespace.
It is configured to discover Kubernetes workloads and resources in
all namespace(s).

Inspect created VulnerabilityReports by:

    kubectl get vulnerabilityreports --all-namespaces -o wide

Inspect created ConfigAuditReports by:

    kubectl get configauditreports --all-namespaces -o wide

Inspect the work log of trivy-operator by:

    kubectl logs -n trivy deployment/trivy-operator

## promtail

Verify the application is working by running these commands:
* kubectl --namespace monitoring port-forward daemonset/promtail 3101
* curl http://127.0.0.1:3101/metrics

## loki

Installed components:
* grafana-agent-operator
* loki

## kube-prometheus-stack

kube-prometheus-stack has been installed. Check its status by running:
  kubectl --namespace monitoring get pods -l "release=kube-prometheus-stack"

Visit https://github.com/prometheus-operator/kube-prometheus for instructions on how to create & configure Alertmanager and Prometheus instances using the Operator.

## ingress-nginx

The ingress-nginx controller has been installed.
Get the application URL by running these commands:
  export HTTP_NODE_PORT=$(kubectl get service --namespace ingress ingress-nginx-controller --output jsonpath="{.spec.ports[0].nodePort}")
  export HTTPS_NODE_PORT=$(kubectl get service --namespace ingress ingress-nginx-controller --output jsonpath="{.spec.ports[1].nodePort}")
  export NODE_IP="$(kubectl get nodes --output jsonpath="{.items[0].status.addresses[1].address}")"

  echo "Visit http://${NODE_IP}:${HTTP_NODE_PORT} to access your application via HTTP."
  echo "Visit https://${NODE_IP}:${HTTPS_NODE_PORT} to access your application via HTTPS."

An example Ingress that makes use of the controller:
  apiVersion: networking.k8s.io/v1
  kind: Ingress
  metadata:
    name: example
    namespace: foo
  spec:
    ingressClassName: nginx
    rules:
      - host: www.example.com
        http:
          paths:
            - pathType: Prefix
              backend:
                service:
                  name: exampleService
                  port:
                    number: 80
              path: /
    # This section is only required if TLS is to be enabled for the Ingress
    tls:
      - hosts:
        - www.example.com
        secretName: example-tls

If TLS is enabled for the Ingress, a Secret containing the certificate and key must also be provided:

  apiVersion: v1
  kind: Secret
  metadata:
    name: example-tls
    namespace: foo
  data:
    tls.crt: <base64 encoded cert>
    tls.key: <base64 encoded key>
  type: kubernetes.io/tls

## argo-cd

In order to access the server UI you have the following options:

1. kubectl port-forward service/argo-cd-argocd-server -n argocd 8080:443

    and then open the browser on http://localhost:8080 and accept the certificate

2. enable ingress in the values file `server.ingress.enabled` and either
      - Add the annotation for ssl passthrough: https://argo-cd.readthedocs.io/en/stable/operator-manual/ingress/#option-1-ssl-passthrough
      - Set the `configs.params."server.insecure"` in the values file and terminate SSL at your ingress: https://argo-cd.readthedocs.io/en/stable/operator-manual/ingress/#option-2-multiple-ingress-objects-and-hosts


After reaching the UI the first time you can login with username: admin and the random password generated during the installation. You can find the password by running:

kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

(You should delete the initial secret afterwards as suggested by the Getting Started Guide: https://argo-cd.readthedocs.io/en/stable/getting_started/#4-login-using-the-cli)

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

## RBAC

The directory `/etc/kubernetes/pki/` of a control-plane node typically contains the Public Key Infrastructure (PKI) assets used by the Kubernetes control-plane components for secure communication and authentication within the cluster.

```bash
# Retrieving cluster's Certificate Authority (CA) key
docker cp k8slab-control-plane:/etc/kubernetes/pki/ca.key cluster-ca.key

# Retrieving cluster's Certificate Authority (CA) certificate
docker cp k8slab-control-plane:/etc/kubernetes/pki/ca.crt cluster-ca.crt
```

In a real environment, these tokens would typically be incorporated into CI/CD secrets.
However, for the purposes of this simulation, let's store them in files instead.

## kubeconfig

### Setting root user in kubeconfig

```bash
# Setting user entry in kubeconfig
kubectl config set-credentials k8slab-root --client-key=root.key --client-certificate=root.crt --embed-certs=true

# Setting context entry in kubeconfig
kubectl config set-context k8slab-root --cluster=k8slab --user=k8slab-root
```

## cluster-toolkit

These tools can be installed in 3 ways:

- Using Helm
- Using Terraform
- Using Argo CD (in this case, Argo CD must be installed first with Helm or Terraform)

Let's use Terraform!

## argocd

Using the --grpc-web flag because ingressGrpc is not yet configured

## RBAC and Namespace Configuration

This step involves configuring Role-Based Access Control (RBAC) resources,
as well as setting namespace limit ranges and resource quotas.

KinD automatically sets up a kubeconfig to access the cluster, but we won't use it.
Instead, we will set up the kubeconfig from scratch.

## cluster-toolkit argocd-mode

We'll use Terraform to install Argo CD and then use Argo CD to install the other tools.

### Installing Argo CD with Terraform (~5 minutes)

We'll use the Terraform `-target` option to limit the operation to only the `helm_release.argocd_stack` resource and its dependencies.
As argocd-stack depends on networking-stack, the networking-stack will also be installed.

As the `-target` option is for exceptional use only,
Terraform will warn "Resource targeting is in effect" and "Applied changes may be incomplete",
but for the purposes of this simulation you can ignore these messages.

```bash
cluster_toolkit_credentials_terraform="
  -var cluster_endpoint=$(cat cluster-endpoint.txt)
  -var cluster_ca_certificate=$(realpath cluster-ca.crt)
  -var service_account_token=$(realpath cluster-toolkit.token)
"

terraform -chdir=cluster-toolkit init

TF_LOG=INFO \
terraform -chdir=cluster-toolkit \
apply $cluster_toolkit_credentials_terraform \
-auto-approve \
-parallelism=1 \
-target=helm_release.argocd_stack
```

```bash
# Uninstalling cluster toolkit that were installed with argocd
kubectl --server=$(cat cluster-endpoint.txt) --token=$(cat argocd-application-deployer.token) \
delete \
-n argocd \
-f argocd/toolkit-applications/ \
-l selection=toolkit-applications

# Uninstalling argocd stack and its dependencies
terraform -chdir=cluster-toolkit \
destroy \
-var cluster_ca_certificate=../cluster-ca.crt \
-var service_account_token=../cluster-toolkit.token \
-var cluster_endpoint=$(cat cluster-endpoint.txt) \
-auto-approve
```

### Installing cluster toolkit with Argo CD

```bash
argocd_application_deployer_credentials_helm="
  --kube-apiserver=$(cat cluster-endpoint.txt)
  --kube-ca-file=$(realpath cluster-ca.crt)
  --kube-token=$(cat argocd-application-deployer.token)
"

release=cluster-toolkit-argocd-apps
chart=./cluster-toolkit/.argocd-apps
values=./cluster-toolkit/.argocd-apps/values.yaml
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
