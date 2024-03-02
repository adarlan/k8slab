#!/bin/bash
set -ex

__main__() {
    stop_and_remove_kind_cluster_nodes
    remove_gitignored_files
}

stop_and_remove_kind_cluster_nodes() {
    docker ps -a --format "{{.Names}}" | grep "^k8slab-" | while read -r container_name; do
        docker stop "$container_name" >/dev/null 2>&1
        docker rm "$container_name" >/dev/null 2>&1
    done
}

remove_gitignored_files() {
    git clean -Xf
    rm -rf .terraform
}

__main__
