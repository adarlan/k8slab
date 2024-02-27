#!/bin/bash
set -e

up() {
    terraform_config
    terraform_apply_config_adapter
    terraform_apply_kind_cluster
    terraform_apply_kind_toolkit
    kubectl_config
    helm_config
    argocd_config
    deploy_app hello-world
}

terraform_config() {
    TF_VERSION="1.7.3"
    tfenv install $TF_VERSION
    tfenv use $TF_VERSION
}

terraform_apply_config_adapter() {
    terraform -chdir=config-adapter init
    # TF_LOG="INFO" \
    terraform -chdir=config-adapter apply -var-file=./../config.tfvars -auto-approve
    terraform -chdir=config-adapter output -json kind_cluster_config > kind-cluster-config.json
    terraform -chdir=config-adapter output -json kind_toolkit_config > kind-toolkit-config.json
}

terraform_apply_kind_cluster() {
    terraform -chdir=kind-cluster init
    # TF_LOG="INFO" \
    terraform -chdir=kind-cluster apply -var-file=./../kind-cluster-config.json
    terraform -chdir=kind-cluster output -json > kind-cluster-output.json
}

terraform_apply_kind_toolkit() {
    terraform -chdir=kind-toolkit init
    # TF_LOG="INFO" \
    terraform -chdir=kind-toolkit apply -var-file=./../kind-toolkit-config.json -parallelism=1
    terraform -chdir=kind-toolkit output -json > kind-toolkit-output.json
}

info_value() {
    jq --raw-output .info.value.${2} ${1}-output.json
}

kubectl_config() {

    kubectl config use-context kind-k8slab
    return 0

    CLUSTER_NAME=$(terraform output -raw cluster_name)
    CLUSTER_ENDPOINT=$(terraform output -raw cluster_endpoint)
    USER_NAME=${CLUSTER_NAME}
    CONTEXT_NAME=$USER_NAME

    terraform output -raw cluster_ca_certificate > ca.crt
    terraform output -raw client_key             > client.key
    terraform output -raw client_certificate     > client.crt

    kubectl config set-cluster     $CLUSTER_NAME --server=$CLUSTER_ENDPOINT --certificate-authority=ca.crt --embed-certs=true
    kubectl config set-credentials $USER_NAME    --client-key=client.key --client-certificate=client.crt --embed-certs=true
    kubectl config set-context     $CONTEXT_NAME --user=$USER_NAME --cluster=$CLUSTER_NAME

    kubectl config use-context $CONTEXT_NAME
    kubectl cluster-info

    return 0

    KUBECONFIG=kubeconfig:~/.kube/config kubectl config view --merge --flatten > ~/.kube/config
}

helm_config() {
    return 0
}

argocd_config() {
    HOST=$(info_value     kind-toolkit argocd.host)
    PORT=$(info_value     kind-toolkit argocd.port)
    USERNAME=$(info_value kind-toolkit argocd.username)
    PASSWORD=$(info_value kind-toolkit argocd.password)
    argocd login --insecure $HOST:$PORT --username $USERNAME --password $PASSWORD
}

deploy_app() {
    kubectl apply -f ../argocd-apps/${1}.yaml
}

up

# deploy-app hello-world
# deploy-app python-crud

# info
