#!/bin/bash
set -e

__main__() {
    
    terraform_config

    terraform -chdir=config-adapter init
    # TF_LOG="INFO" \
    terraform -chdir=config-adapter apply -var-file=./../config.tfvars
    terraform -chdir=config-adapter output -json kind_cluster_config > cluster-config.json
    terraform -chdir=config-adapter output -json kind_toolkit_config > toolkit-config.json
    terraform -chdir=config-adapter output -json application_deployment_config > deploy-config.json
}

terraform_config() {
    TF_VERSION="1.7.3"
    tfenv install $TF_VERSION
    tfenv use $TF_VERSION
}

__main__
