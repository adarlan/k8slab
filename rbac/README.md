# Role Based Access Control

The local cluster we previously created provides a client key and certificate grating full access.
We could use these credentials to do everything in the cluster,
but we will only use it to create less privileged credentials, simulating a real environment.

Roles:

- `developer`
- `administrator`
<!-- - `toolkit-installer` -->
<!-- - `application-deployer` -->

Users:

- `johndev`: John Dev is responsible for developing and deploying applications within the Kubernetes environment.
- `janeops`: Jane Ops focuses on the operational aspects of managing the Kubernetes environment.

<!-- Service accounts: -->
<!--  -->
<!-- - `toolkit-installer`: For the GitHub Actions that installs tools such as ArgoCD, Ingress-NGINX, Prometheus, etc. -->
<!-- - `application-deployer`: For the GitHub Actions that deploys applications. -->

Let's start by creating these directories to create the RBAC-related manifests and user files.

```bash
mkdir -p manifests johndev janeops
```

## Roles and ClusterRoles

Cluster managers are tasked with creating Roles and ClusterRoles to define common access permissions.

### Creating the 'developer' Role

The 'developer' role grants permissions to create, get, list, update and delete pod resources in the 'dev' namespace.
As a role is namespaced, the namespace must be created first.

```bash
# Create the namespace
kubectl create namespace dev

# Create the role manifest
cat << EOF > manifests/developer.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: developer
  namespace: dev
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["create", "get", "list", "update", "delete"]
EOF

# Create the role resource
kubectl apply -f manifests/developer.yaml
```

### Creating the 'administrator' ClusterRole

The 'administrator' ClusterRole provides unrestricted access across all resources in the cluster.
A cluster role is not namespaced, which means it is valid for the entire cluster.

```bash
# Create the cluster role manifest
cat << EOF > manifests/administrator.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: administrator
rules:
- apiGroups: ["*"]
  resources: ["*"]
  verbs: ["*"]
EOF

# Create the cluster role resource
kubectl apply -f manifests/administrator.yaml
```

## Private Key and Certificate Signing Request

To gain access to the cluster, each user must generate a private key and a Certificate Signing Request (CSR).
The private key must be kept private, meanwhile the CSR file should be shared with the cluster managers.

### Jane Ops creates her private key and CSR

```bash
# Create the private key file
openssl genrsa -out janeops/janeops.key 2048

# Create the CSR file
openssl req -new -key janeops/janeops.key -out janeops/janeops.csr -subj "/CN=Jane Ops"
```

### John Dev creates his private key and CSR

```bash
# Create the private key file
openssl genrsa -out johndev/johndev.key 2048

# Create the CSR file
openssl req -new -key johndev/johndev.key -out johndev/johndev.csr -subj "/CN=John Dev"
```

## Creating the CSR resources into the cluster

Upon receiving the CSR files from the users, the cluster managers proceed to create the corresponding CSR resources within the cluster.

### Creating CSR resource for Jane Ops

```bash
# Create the CSR manifest
cat << EOF > manifests/janeops.yaml
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: janeops
spec:
  request: $(cat janeops/janeops.csr | base64 | tr -d '\n')
  signerName: kubernetes.io/kube-apiserver-client
  expirationSeconds: 31536000
  usages:
  - client auth
EOF

# Create the CSR resource
kubectl create -f manifests/janeops.yaml
```

### Creating CSR resource for John Dev

```bash
# Create the CSR manifest
cat << EOF > manifests/johndev.yaml
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: johndev
spec:
  request: $(cat johndev/johndev.csr | base64 | tr -d '\n')
  signerName: kubernetes.io/kube-apiserver-client
  expirationSeconds: 31536000
  usages:
  - client auth
EOF

# Create the CSR resource
kubectl create -f manifests/johndev.yaml
```

## Approving the user certificates

The next step involves a cluster manager approving the certificates.
Subsequently, the approved certificate files must be shared with the respective users.

### Approving Jane Ops certificate

```bash
# Approve the certificate
kubectl certificate approve janeops

# Create the certificate file
kubectl get csr janeops -o jsonpath='{.status.certificate}' | base64 --decode > janeops/janeops.crt
```

### Approving John Dev certificate

```bash
# Approve the certificate
kubectl certificate approve johndev

# Create the certificate file
kubectl get csr johndev -o jsonpath='{.status.certificate}' | base64 --decode > johndev/johndev.crt
```

## RoleBinding and ClusterRoleBinding

With roles established and user certificates duly approved and issued,
the final step for the cluster managers is to bind these roles with their respective users.
This action effectively grants them access to the cluster.

### Binding 'developer' Role to 'John Dev' User

```bash
# Create the cluster role binding manifest
cat << EOF > manifests/developer-johndev.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: developer-johndev
  namespace: dev
subjects:
- kind: User
  name: "John Dev"
  namespace: dev
roleRef:
  kind: Role
  name: developer
  apiGroup: rbac.authorization.k8s.io
EOF

# Create the cluster role binding resource
kubectl apply -f manifests/developer-johndev.yaml
```

### Binding 'administrator' ClusterRole to 'Jane Ops' User

```bash
# Create the cluster role binding manifest
cat << EOF > manifests/administrator-janeops.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: administrator-janeops
subjects:
- kind: User
  name: "Jane Ops"
roleRef:
  kind: ClusterRole
  name: administrator
  apiGroup: rbac.authorization.k8s.io
EOF

# Create the cluster role binding resource
kubectl apply -f manifests/administrator-janeops.yaml
```

## Cluster's endpoint and Certificate Authority (CA) certificate

In order to connect to the cluster,
users will need the cluster's CA certificate and the cluster endpoint.
Let's retrieve this information from the cluster we previously provisioned with Terraform.

```bash
terraform -chdir=../local-cluster output -raw ca_certificate | tee johndev/cluster-ca.crt janeops/cluster-ca.crt
terraform -chdir=../local-cluster output -raw endpoint | tee johndev/cluster-endpoint.txt janeops/cluster-endpoint.txt
```

## Creating kubeconfig files

With their private keys, signed certificates, as well as the cluster's CA certificate and endpoint in hand, John Dev and Jane Ops are now tasked with assembling this information to configure their individual kubeconfig files.

### Creating 'Jane Ops' kubeconfig

```bash
# Set kubeconfig path
export KUBECONFIG=janeops/kubeconfig

# Set cluster entry
kubectl config set-cluster k8slab --server=$(cat janeops/cluster-endpoint.txt) --certificate-authority=janeops/cluster-ca.crt --embed-certs=true

# Set user entry
kubectl config set-credentials janeops --client-certificate=janeops/janeops.crt --client-key=janeops/janeops.key --embed-certs=true

# Set context entry
kubectl config set-context janeops --cluster=k8slab --user=janeops
```

### Creating 'John Dev' kubeconfig

```bash
# Set kubeconfig path
export KUBECONFIG=johndev/kubeconfig

# Set cluster entry
kubectl config set-cluster k8slab --server=$(cat johndev/cluster-endpoint.txt) --certificate-authority=johndev/cluster-ca.crt --embed-certs=true

# Set user entry
kubectl config set-credentials johndev --client-certificate=johndev/johndev.crt --client-key=johndev/johndev.key --embed-certs=true

# Set context entry
kubectl config set-context johndev --cluster=k8slab --namespace=dev --user=johndev
```

## Merging kubeconfig files into ~/.kube/config

With separate kubeconfig files prepared for each user, let's merge them into the `~/.kube/config` file.
This allows simulating any user by simply switching the current context.

```bash
# Set kubeconfig path to all kubeconfig files, including your default kubeconfig
export KUBECONFIG=johndev/kubeconfig:janeops/kubeconfig:~/.kube/config

# Create a new kubeconfig file containing the merged configuration
kubectl config view --merge --flatten > kubeconfig

# Backup your default kubeconfig file
cp ~/.kube/config ~/.kube/config-backup-$(date '+%Y-%m-%d-%H-%M-%S')

# Copy the merged kubeconfig file to the default location
cp kubeconfig ~/.kube/config

# Set kubeconfig path to the default location
export KUBECONFIG=~/.kube/config
```

### Checking 'Jane Ops' permissions

```bash
# Set current context
kubectl config use-context janeops

# List permissions
kubectl auth can-i --list
```

### Checking 'John Dev' permissions

```bash
# Set current context
kubectl config use-context johndev

# List permissions
kubectl auth can-i --list
```
