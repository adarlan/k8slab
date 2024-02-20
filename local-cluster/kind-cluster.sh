#!/bin/bash
set -ex

apply() {
    export TF_LOG=INFO
    terraform -chdir=kind-cluster init
    terraform -chdir=kind-cluster apply -var-file=../kind-cluster.tfvars -var-file=../port-mappings.tfvars
}

destroy() {
    export TF_LOG=INFO
    terraform -chdir=kind-cluster init
    terraform -chdir=kind-cluster destroy -var-file=../kind-cluster.tfvars -var-file=../port-mappings.tfvars
}

plan-apply() {
    export TF_LOG=INFO
    terraform -chdir=kind-cluster init
    terraform -chdir=kind-cluster plan -var-file=../kind-cluster.tfvars -var-file=../port-mappings.tfvars -out apply.tfplan
}

plan-destroy() {
    export TF_LOG=INFO
    terraform -chdir=kind-cluster init
    terraform -chdir=kind-cluster plan -destroy -var-file=../kind-cluster.tfvars -var-file=../port-mappings.tfvars -out destroy.tfplan
}

apply-with-plan() {
    export TF_LOG=INFO
    terraform -chdir=kind-cluster apply apply.tfplan
}

destroy-with-plan() {
    export TF_LOG=INFO
    terraform -chdir=kind-cluster apply destroy.tfplan
}

force-destroy() {
    docker ps -a --format "{{.Names}}" | grep "^k8slab-" | while read -r container_name; do
        docker stop "$container_name" >/dev/null 2>&1
        docker rm "$container_name" >/dev/null 2>&1
    done
    cd kind-cluster
    git clean -Xf
    rm -rf .terraform
    cd ..
}

$1
