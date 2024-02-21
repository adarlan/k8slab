# K8sLab

A collection of Infrastructure-as-Code modules, CI/CD workflows, and other utilities designed to simplify the provisioning and management of Kubernetes clusters across different environments, including major cloud providers and local setups. It creates a ready-to-use Kubernetes platform bundled with popular open-source tools and example applications.

## Features

- Automated provisioning of [Kubernetes](https://kubernetes.io/) clusters, whether in the cloud with [Amazon EKS](https://aws.amazon.com/eks/) or locally with [Kind](https://kind.sigs.k8s.io/).
- Infrastructure provisioning with [Terraform](https://www.terraform.io/).
- Package management with [Helm](https://helm.sh/) for deploying Kubernetes rousources.
- [Ingress NGINX Controller](https://github.com/kubernetes/ingress-nginx) for managing incoming traffic to the cluster.
- Continuous delivery using [Argo CD](https://argoproj.github.io/cd/) for GitOps workflows.
- Monitoring and alerting with [Prometheus](https://prometheus.io/) and [Grafana](https://grafana.com/grafana/).
- [Trivy Operator](https://aquasecurity.github.io/trivy-operator) to continuously scan the Kubernetes cluster for security issues.
- [Karpenter](https://karpenter.sh/) for automatic node scaling based on resource usage.
- Continuous integration pipelines using [GitHub Actions](https://github.com/features/actions).
- [Docker](https://www.docker.com/) for containerization of applications.

## Quick Start

Tap into the potential of Terraform to get up and running with a local Kubernetes cluster preconfigured with essential tools such as Argo CD, Ingress NGINX, Prometheus, Grafana, and more. Follow a few straightforward steps to deploy a fully configured Hello World application, gaining insights into CI/CD, service routing, observability, security, and other functionalities.

### 1. Clone this repository

```shell
git clone https://github.com/adarlan/k8slab.git
```

### 2. Navigate to the local-cluster directory inside the repository

```shell
cd k8slab/local-cluster
```

### 3. Create the local Kubernetes cluster with Terraform

Execute the following `terraform` commands to create a Kind (Kubernetes-in-Docker) cluster in your local environment.
You could use the `kind` CLI tool, but if you plan to use Terraform in production you should use it in development too.

```shell
terraform -chdir=kind-cluster init
terraform -chdir=kind-cluster apply -var-file=../kind-cluster.tfvars -var-file=../port-mappings.tfvars
```

Once Terraform completes its tasks, you can use `kubectl` to manage your cluster directly from the command line.

```txt
$ kubectl get nodes
NAME                   STATUS   ROLES           AGE     VERSION
k8slab-control-plane   Ready    control-plane   6m25s   v1.29.1
k8slab-worker          Ready    <none>          5m51s   v1.29.1
...
```

### 4. Install essential tools in the cluster using Terraform

Execute the following commands to install indispensable Helm charts into your cluster, including `argo-cd`, `ingress-nginx`, `kube-prometheus-stack`, and `trivy-operator`.

```shell
terraform -chdir=cluster-toolkit init
terraform -chdir=cluster-toolkit apply -var-file=../cluster-toolkit.tfvars -var-file=../port-mappings.tfvars -parallelism=1
```

### 5. Retrieve login information for dashboard access

The following command provides URLs, usernames, and passwords required to access dashboards and tools installed on your cluster.

```shell
terraform -chdir=cluster-toolkit output login_info
```

You can use this information to access insightful dashboards for tools like Argo CD, Prometheus, and Grafana directly from your web browser.

![Dashboards screenshot](./docs/img/dashboards.png)

### 6. Deploy the Hello World application using Argo CD

Apply the Argo CD application configuration using the following command, kickstarting the deployment process for the `hello-world` application.

```shell
kubectl apply -f ../argocd-apps/hello-world.yaml
```

Open Argo CD in your browser to manage the application deployment.

![Argo CD screenshot](./docs/img/argocd-2.png)

<!-- TODO the hello-world app manifests are packaged into Helm chart in the ./helm-charts/hello-world dir. since its configuration change, argo cd will detect and sync -->

<!-- TODO the source code of the hello-world app is in ./apps/hello-world. when it is tagged, github actions builds the docker image... develop branch... -->

<!-- TODO Open the Hello World application in your browser... the app is configured with ingress... dev, stg, prd... -->

<!-- TODO Metrics, ServiceMonitor, etc -->

<!-- TODO Trivy reports? -->

### 7. Destroy your cluster

Once you've finished exploring and experimenting with your local Kubernetes environment,
it's important to clean up resources.

```shell
terraform -chdir=cluster-toolkit destroy -var-file=../cluster-toolkit.tfvars -var-file=../port-mappings.tfvars
terraform -chdir=kind-cluster destroy -var-file=../kind-cluster.tfvars -var-file=../port-mappings.tfvars
```

## Contributing

Contributions are welcome! Feel free to submit issues or pull requests for enhancements, bug fixes, or new features.

## License

This project is licensed under the [Apache 2.0 License](./LICENSE).
