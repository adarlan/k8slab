#!/bin/bash
set -e

terraform-config() {
    export TF_LOG=INFO
    TERRAFORM_VERSION="1.7.3"
    tfenv install $TERRAFORM_VERSION
    tfenv use $TERRAFORM_VERSION
}

terraform-apply() {
    terraform -chdir=$1 init
    terraform -chdir=$1 apply -var-file=./../$2 -parallelism=1
}

terraform-destroy() {
    terraform -chdir=$1 init
    terraform -chdir=$1 destroy -var-file=./../$2
}

terraform-plan-apply() {
    terraform -chdir=$1 init
    terraform -chdir=$1 plan -var-file=./../$2 -out apply.tfplan
}

terraform-plan-destroy() {
    terraform -chdir=$1 init
    terraform -chdir=$1 plan -destroy -var-file=./../$2 -out destroy.tfplan
}

terraform-apply-with-plan() {
    terraform -chdir=$1 apply apply.tfplan -parallelism=1
}

terraform-destroy-with-plan() {
    terraform -chdir=$1 apply destroy.tfplan
}

terraform-output-raw() {
    TF_LOG="" terraform -chdir=$1 output -raw $2
}

terraform-output-json() {
    TF_LOG="" terraform -chdir=$1 output -json $2
}

terraform-output-pretty() {
    TF_LOG="" terraform -chdir=$1 output -json $2 | jq .
}

force-destroy() {
    if [ "$1" = "kind-cluster" ]; then
        docker ps -a --format "{{.Names}}" | grep "^k8slab-" | while read -r container_name; do
            docker stop "$container_name" >/dev/null 2>&1
            docker rm "$container_name" >/dev/null 2>&1
        done
    # else
    #     kubectl config use-context kind-k8slab
    #     helm uninstall $1
    fi
    cd $1
    git clean -Xf
    rm -rf .terraform
    cd -
}

git-clean() {
    cd $1
    git clean -Xf
    rm -rf .terraform
    cd -
}

deploy-app() {
    kubectl apply -f ../argocd-apps/${1}.yaml
}

undeploy-app() {
    kubectl delete -f ../argocd-apps/${1}.yaml
}

kubectl-config() {

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

helm-config() {
    return 0
}

argocd-config() {

    argocd login --insecure localhost:8011 --username admin --password $(terraform-output-raw argo-cd initial_admin_password)
    return 0

    HOST=localhost
    PORT=$(terraform -chdir=cluster-toolkit output -json port_mappings_by_name | jq -r .argocd.host_port)
    USERNAME=admin
    PASSWORD=$(kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath='{.data.password}' | base64 --decode)
    argocd login --insecure $HOST:$PORT --username $USERNAME --password $PASSWORD
}

info() {
    kubectl cluster-info
    echo
    echo "--------------------------------------------------------------------------------"
    echo
    echo -e "\e[1;34mCLUSTER NODES\e[0m"
    echo
    kubectl get nodes
    echo
    echo "--------------------------------------------------------------------------------"
    echo
    echo -e "\e[1;34mCLUSTER TOOLKIT\e[0m"
    echo
    helm list -A
    echo
    echo "--------------------------------------------------------------------------------"
    echo
    echo -e "\e[1;34mAPPLICATIONS\e[0m"
    echo
    argocd app list
    echo
    echo "--------------------------------------------------------------------------------"
    echo
    echo -e "\e[1;34mMANAGEMENT CONSOLES\e[0m"
    echo
    echo "Argo CD: http://localhost:8011"
    echo "Username: admin"
    echo "Password: $(terraform-output-raw argo-cd initial_admin_password)"
    echo
    echo "Prometheus: http://localhost:8065"
    echo
    echo "Grafana: http://localhost:8066"
    echo "Username: $(terraform-output-raw kube-prometheus-stack grafana_admin_user)"
    echo "Password: $(terraform-output-raw kube-prometheus-stack grafana_admin_password)"
    echo
    echo "--------------------------------------------------------------------------------"
    echo
    echo -e "\e[1;34mHELLO WORLD APPLICATION\e[0m"
    echo
    echo "Hello, Devs! (development)"
    echo "http://dev.localhost/hello"
    echo "http://dev.localhost/hello/healthz"
    echo
    echo "Hello, QA Folks! (staging)"
    echo "http://stg.localhost/hello"
    echo "http://stg.localhost/hello/healthz"
    echo
    echo "Hello, Users! (production)"
    echo "http://hello.localhost"
    echo "http://hello.localhost/healthz"
    echo
    echo "--------------------------------------------------------------------------------"
}

plankton() {
    docker run -it -v /var/run/docker.sock:/var/run/docker.sock -v $PWD:/workdir -w /workdir -p 1329:1329 adarlan/plankton
    # TODO add user, because it is creating the .plankton directory with root user
}
