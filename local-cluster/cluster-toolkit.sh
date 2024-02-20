#!/bin/bash
set -ex

apply() {
    export TF_LOG=INFO
    terraform -chdir=cluster-toolkit init
    terraform -chdir=cluster-toolkit apply -var-file=../cluster-toolkit.tfvars -var-file=../port-mappings.tfvars -parallelism=1
}

destroy() {
    export TF_LOG=INFO
    terraform -chdir=cluster-toolkit init
    terraform -chdir=cluster-toolkit destroy -var-file=../cluster-toolkit.tfvars -var-file=../port-mappings.tfvars
}

plan-apply() {
    export TF_LOG=INFO
    terraform -chdir=cluster-toolkit init
    terraform -chdir=cluster-toolkit plan -var-file=../cluster-toolkit.tfvars -var-file=../port-mappings.tfvars -out apply.tfplan
}

plan-destroy() {
    export TF_LOG=INFO
    terraform -chdir=cluster-toolkit init
    terraform -chdir=cluster-toolkit plan -destroy -var-file=../cluster-toolkit.tfvars -var-file=../port-mappings.tfvars -out destroy.tfplan
}

apply-with-plan() {
    export TF_LOG=INFO
    terraform -chdir=cluster-toolkit apply -parallelism=1 apply.tfplan
}

destroy-with-plan() {
    export TF_LOG=INFO
    terraform -chdir=cluster-toolkit apply destroy.tfplan
}

force-destroy() {
    # TODO kubectl use $cluster_name && helm uninstall all charts || true
    cd cluster-toolkit
    git clean -Xf
    rm -rf .terraform
    cd ..
}

argocd-login() {
    HOST=localhost
    PORT=$(terraform -chdir=cluster-toolkit output -json port_mappings_by_name | jq -r .argocd.host_port)
    USERNAME=admin
    PASSWORD=$(kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath='{.data.password}' | base64 --decode)
    argocd login --insecure $HOST:$PORT --username $USERNAME --password $PASSWORD
}

output-login-info() {
    terraform -chdir=cluster-toolkit output login_info
}

$1
