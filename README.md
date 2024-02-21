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

Use Terraform to quickly set up a local Kubernetes cluster with essential tools like Argo CD, Ingress NGINX, Prometheus, Grafana, and more. Deploy a Hello World application in just a few steps to learn about CI/CD, service routing, observability, and security.

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
You could use the `kind` CLI, but if you plan to use Terraform in production you should use it in development too.

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

### 8. Open the Hello World application in your browser

Access to the following URL in your browser to open the Hello World application:

[http://hello.localhost](http://hello.localhost)

### 9. Explore the Hello World application configuration

The Hello World application is organized into multiple directories and files, simulating real-world scenarios where components might reside in separate repositories.

In this repository, the application configuration is distributed across the following directories and files:

- [`apps/hello-world/`](./apps/hello-world/): contains the Python source code of the application along with a `Dockerfile` to build its image.
- [`.github/workflows/hello-world.yaml`](./.github/workflows/hello-world.yaml): contains the GitHub Actions configuration responsible for testing the application. Upon successfull tests, it builds and pushes the Docker image to a container registry.
- [`helm-charts/hello-world/`](./helm-charts/hello-world/): contains the application Helm chart and its pre-configured Kubernetes resources, including files like `Deployment.yaml`, `Service.yaml`, `ConfigMap.yaml`, and more.
- [`argocd-apps/hello-world.yaml`](./argocd-apps/hello-world.yaml): contains the Argo CD configuration necessary for managing the deployment of the application.

Below are some code snippets extracted from this configuration to provide insight into the end-to-end process.

#### Ingress rules

You may have noticed that the URL `http://hello.localhost` doesn't include a port number like `:8080`. Here's a simplified snippet demonstrating how the `hello-world-ingress` is configured to ensure that incoming traffic directed to `hello.localhost` is routed to the port `8080` of the `hello-world-service`:

```yaml
# helm-charts/hello-world/templates/Ingress.yaml

apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: hello-world-ingress
  # (...)
spec:
  rules:
  - host: hello.localhost
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: hello-world-service
            port:
              number: 8080
```

#### Argo CD application source

As configurations in the application Helm chart are updated and pushed to the repository, Argo CD automatically detects these changes and synchronizes them to ensure that the deployed state within the cluster aligns with the desired state. See how this is configured:

```yaml
# argocd-apps/hello-world.yaml

apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: hello-world-application-set
  namespace: argocd
spec:
  template:
    spec:
      source:
        repoURL: https://github.com/adarlan/k8slab.git
        path: helm-charts/hello-world
# (...)
```

#### Helm templates

The reason for packaging the application manifests into a Helm chart is to utilize Helm template directives, allowing Argo CD to apply distinct values during application deployment across multiple environments. See this example:

```yaml
# helm-charts/hello-world/templates/ConfigMap.yaml

apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ .Release.Name }}-configmap
data:
  greetingMessage: {{ .Values.greetingMessage }}
```

#### Argo CD generators

Below is an example of the Argo CD configuration for deploying the application in multiple environments, with distinct elements for each environment.

```yaml
# argocd-apps/hello-world.yaml

apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: hello-world-application-set
  namespace: argocd
spec:
  generators:
  - list:
      elements:
      - environment: staging
        targetRevision: v1.6.0-rc
        releaseName: hello-world-staging
        destinationCluster: staging-cluster
        greetingMessage: Hello, Staging Environment!
        # (...)

      - environment: production
        targetRevision: v1.5.0
        releaseName: hello-world-production
        destinationCluster: production-cluster
        greetingMessage: Hello, Production Environment!
        # (...)
# (...)
```

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
