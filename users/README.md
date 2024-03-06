# Role-Based Access Control (RBAC)

The local cluster we previously created provides root user credentials.
We could use these credentials to perform any action in the cluster,
but we will only use it to create less privileged users, simulating a real environment.

```bash
kubectl config use-context k8slab-root
```

## Creating Role and ClusterRole resources

Roles and ClusterRoles can be used to define common access permissions.

Let's create a role called 'developer' and a cluster role called 'administrator'.

### Creating the 'developer' role

The 'developer' role grants permissions to create, get, list, update and delete pod resources in the 'dev' namespace.
As a role is namespaced, the namespace must be created first.

```bash
# Create the namespace
kubectl create namespace dev

# Create the role manifest file
cat << EOF > developer-role.yaml
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
kubectl apply -f developer-role.yaml
```

### Creating the 'administrator' cluster role

The 'administrator' cluster role provides unrestricted access across all resources in the cluster.
A cluster role is not namespaced, which means it is valid for the entire cluster.

```bash
# Create the cluster role manifest file
cat << EOF > administrator-cluster-role.yaml
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
kubectl apply -f administrator-cluster-role.yaml
```

## Private Key and Certificate Signing Request (CSR)

To gain access to the cluster, each user must generate a private key and a CSR file.
The private key must be kept private, while the CSR file should be shared with the cluster managers in order to grant user access.

Let's consider two dummy users:

- John Dev, who will be given the 'developer' role
- Jane Ops, who will be given the 'administrator' cluster role

### Creating 'Jane Ops' private key and CSR

```bash
# Create the private key file
openssl genrsa -out janeops.key 2048

# Create the CSR file
openssl req -new -key janeops.key -out janeops.csr -subj "/CN=Jane Ops"
```

### Creating 'John Dev' private key and CSR

```bash
# Create the private key file
openssl genrsa -out johndev.key 2048

# Create the CSR file
openssl req -new -key johndev.key -out johndev.csr -subj "/CN=John Dev"
```

## Creating CertificateSigningRequest resources into the cluster

Upon receiving the CSR files from the users, the cluster managers proceed to create the corresponding CSR resources within the cluster.

### Creating CSR resource for Jane Ops

```bash
# Create the CSR manifest file
cat << EOF > janeops-csr.yaml
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: janeops
spec:
  request: $(cat janeops.csr | base64 | tr -d '\n')
  signerName: kubernetes.io/kube-apiserver-client
  expirationSeconds: 31536000
  usages:
  - client auth
EOF

# Create the CSR resource
kubectl create -f janeops-csr.yaml
```

### Creating CSR resource for John Dev

```bash
# Create the CSR manifest file
cat << EOF > johndev-csr.yaml
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: johndev
spec:
  request: $(cat johndev.csr | base64 | tr -d '\n')
  signerName: kubernetes.io/kube-apiserver-client
  expirationSeconds: 31536000
  usages:
  - client auth
EOF

# Create the CSR resource
kubectl create -f johndev-csr.yaml
```

## Approving CertificateSigningRequests and issuing user certificates

The cluster managers' next task is to approve user certificates
and immediately share the certificate files with respective users,
as CertificateSigningRequest resources soon disappear.

### Approving John Dev's certificate

```bash
# Approve the certificate
kubectl certificate approve johndev

# Create the certificate file
kubectl get csr johndev -o jsonpath='{.status.certificate}' | base64 --decode > johndev.crt
```

### Approving Jane Ops' certificate

```bash
# Approve the certificate
kubectl certificate approve janeops

# Create the certificate file
kubectl get csr janeops -o jsonpath='{.status.certificate}' | base64 --decode > janeops.crt
```

## Creating RoleBinding and ClusterRoleBinding resources

With roles established and user certificates duly approved and issued,
the final step for the cluster managers is to bind these roles with their respective users.
This action effectively grants them access to the cluster.

### Binding 'developer' role to John Dev user

```bash
# Create the cluster role binding manifest file
cat << EOF > johndev-developer-role-binding.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: johndev-developer
  namespace: dev
subjects:
- kind: User
  name: "John Dev"
roleRef:
  kind: Role
  name: developer
  apiGroup: rbac.authorization.k8s.io
EOF

# Create the cluster role binding resource
kubectl apply -f johndev-developer-role-binding.yaml
```

### Binding 'administrator' cluster role to Jane Ops user

```bash
# Create the cluster role binding manifest file
cat << EOF > janeops-administrator-cluster-role-binding.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: janeops-administrator
subjects:
- kind: User
  name: "Jane Ops"
roleRef:
  kind: ClusterRole
  name: administrator
  apiGroup: rbac.authorization.k8s.io
EOF

# Create the cluster role binding resource
kubectl apply -f janeops-administrator-cluster-role-binding.yaml
```

## Setting kubeconfig users and contexts

### Setting kubeconfig user and context for John Dev

```bash
# Set user entry
kubectl config set-credentials k8slab-johndev --client-key=johndev.key --client-certificate=johndev.crt --embed-certs=true

# Set context entry
kubectl config set-context k8slab-johndev --cluster=k8slab --user=k8slab-johndev --namespace=dev

# Switch the context
kubectl config use-context k8slab-johndev

# List permissions
kubectl auth can-i --list
```

### Setting kubeconfig user and context for Jane Ops

```bash
# Set user entry
kubectl config set-credentials k8slab-janeops --client-key=janeops.key --client-certificate=janeops.crt --embed-certs=true

# Set context entry
kubectl config set-context k8slab-janeops --cluster=k8slab --user=k8slab-janeops

# Switch the context
kubectl config use-context k8slab-janeops

# List permissions
kubectl auth can-i --list
```

<!-- FUNCTION describe -->
<!--
## Reviewing

```bash
kubectl config use-context k8slab-root

kubectl describe namespace dev

kubectl describe role developer -n dev
kubectl describe clusterrole administrator

kubectl describe csr janeops
kubectl describe csr johndev

kubectl describe rolebinding johndev-developer -n dev
kubectl describe clusterrolebinding janeops-administrator

kubectl config view
```
-->

<!-- FUNCTION clean -->
<!-- CONFIG shellOptions: -x +e -->
## Revoking access, deleting resources, removing files...

```bash
# Switch to the root user context
kubectl config use-context k8slab-root

# Revoke John Dev access
kubectl delete rolebinding johndev-developer -n dev
kubectl delete csr johndev
kubectl config unset contexts.johndev
kubectl config unset users.johndev

# Revoke Jane Ops access
kubectl delete clusterrolebinding janeops-administrator
kubectl delete csr janeops
kubectl config unset contexts.janeops
kubectl config unset users.janeops

# Remove 'developer' role and 'dev' namespace
kubectl delete role developer -n dev
kubectl delete namespace dev

# Remove 'administrator' cluster role
kubectl delete clusterrole administrator

# Remove files (keys, certificates, manifests, etc)
git clean -Xf
```
