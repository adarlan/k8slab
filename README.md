# K8sLab

A collection of IaC modules, CI/CD workflows, and other utilities designed to simplify the provisioning and management of Kubernetes clusters across different environments, including major cloud providers and local setups. It creates a ready-to-use Kubernetes platform bundled with popular open-source tools and example applications.

## Features

- Automated provisioning of [Kubernetes](https://kubernetes.io/) clusters on various cloud providers (e.g., [Amazon EKS](https://aws.amazon.com/eks/)) and local environments using [Kind](https://kind.sigs.k8s.io/)
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

Install manually:

- __Terraform__ | https://developer.hashicorp.com/terraform/install
- __Docker Engine__ | https://docs.docker.com/engine/install/
- __Kubectl__ | https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/
- __Argo CD CLI__ | https://argo-cd.readthedocs.io/en/stable/cli_installation/
- __Helm__ | https://helm.sh/docs/intro/install/

Install using Ansible:

```bash
ansible-playbook local-setup-requirements/ansible-playbook.yaml
```

## Quick Start

### 1. Create the cluster in your local environment

```shell
terraform -chdir=local-environment init
terraform -chdir=local-environment apply -auto-approve
```

<!-- TODO Manage your cluster with `kubectl`, `helm` and `argocd` -->

### 2. Retrieve the Argo CD `admin` password

```bash
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath='{.data.password}' | base64 --decode
```

### 3. Expose the Argo CD server

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

### 4. Open the Argo CD UI in your browser

[https:localhost:8080](https:localhost:8080)

### 5. Destroy the cluster

```shell
terraform -chdir=local-environment destroy -auto-approve
```

## Contributing

Contributions are welcome! Feel free to submit issues or pull requests for enhancements, bug fixes, or new features.

<!-- ## TODO License

This project is licensed under the ??? License. -->
