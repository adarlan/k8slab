# K8sLab

A collection of IaC modules, CI/CD workflows, and other utilities designed to simplify the provisioning and management of Kubernetes clusters across different environments, including major cloud providers and local setups. It creates a ready-to-use Kubernetes platform bundled with popular open-source tools and example applications.

## Features

- Automated provisioning of [Kubernetes](https://kubernetes.io/) clusters on various cloud providers (e.g., [Amazon EKS](https://aws.amazon.com/eks/)) and local environments using [Kind](https://kind.sigs.k8s.io/)
- Integrated cloud networking across top-tier providers such as [Amazon VPC](https://aws.amazon.com/vpc/)
- Continuous delivery using [Argo CD](https://argoproj.github.io/cd/) for GitOps workflows
- [NGINX Ingress Controller](https://kubernetes.github.io/ingress-nginx/) for managing incoming traffic to the cluster
- [Karpenter](https://karpenter.sh/) for automatic node scaling based on resource usage
- Monitoring and alerting with [Prometheus](https://prometheus.io/)
- Package management with [Helm](https://helm.sh/) for deploying Kubernetes rousources
- Infrastructure provisioning with [Terraform](https://www.terraform.io/)
- Continuous integration pipelines using [GitHub Actions](https://github.com/features/actions)
- [Docker](https://www.docker.com/) for containerization of applications
- [Ansible](https://www.ansible.com/) for local environment configuration

## Requirements

To explore and experiment with your local Kubernetes environment, ensure the following components are installed:

- __Terraform__ | https://developer.hashicorp.com/terraform/install
- __Docker Engine__ | https://docs.docker.com/engine/install/
- __Kubectl__ | https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/
- __Helm__ | https://helm.sh/docs/intro/install/
- __Argo CD CLI__ | https://argo-cd.readthedocs.io/en/stable/cli_installation/

<!-- TODO You can simplify the installation process using Ansible:

```bash
ansible-playbook requirements/ansible-playbook.yaml
``` -->

## Quick Start

### 1. Clone this repository

```bash
git clone https://github.com/adarlan/k8slab.git
```

### 2. Navigate to the local environment configuration

```bash
cd k8slab/environments/local
```

### 3. Create a local Kubernetes cluster with Terraform

```shell
terraform init
terraform apply
```

This will create a local Kubernetes cluster,
properly configured with essential tools such as Argo CD, NGINX Ingress, Prometheus, and more.

### 4. Manage your cluster from command line and browser

This script configures your `kubectl`, `helm`, and `argocd` CLIs,
allowing you to manage your cluster directly from the command line.

```bash
./login.sh
```

Additionally, it will output the Argo CD username and password,
enabling access to the Argo CD dashboard in your browser.

<!-- TODO Argo CD dashboard screenshot -->

<!-- TODO Add links for tools and apps -->

### 5. Destroy your cluster

Once you've finished exploring and experimenting with your local Kubernetes environment,
it's important to clean up resources.

```shell
terraform destroy
```

## Contributing

Contributions are welcome! Feel free to submit issues or pull requests for enhancements, bug fixes, or new features.

## License

This project is licensed under the [Apache License 2.0](./LICENSE).
