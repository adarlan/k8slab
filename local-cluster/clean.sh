#!/bin/bash
set -e

__main__() {
    stop_and_remove_kind_cluster_nodes
    git_clean config-adapter
    git_clean kind-cluster
    git_clean kind-toolkit
    git_clean .
    rm -rf app-manifests
}

stop_and_remove_kind_cluster_nodes() {
    docker ps -a --format "{{.Names}}" | grep "^k8slab-" | while read -r container_name; do
        docker stop "$container_name" >/dev/null 2>&1
        docker rm "$container_name" >/dev/null 2>&1
    done
}

git_clean() {
    BACK=$(pwd)
    cd $1
    git clean -Xf
    rm -rf .terraform
    cd $BACK
}

__main__
