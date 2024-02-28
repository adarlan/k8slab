#!/bin/bash
set -e

__main__() {
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
    echo "Argo CD: $(get_toolkit_secret argocd.url)"
    echo "Username: $(get_toolkit_secret argocd.username)"
    echo "Password: $(get_toolkit_secret argocd.password)"
    echo
    echo "Prometheus: $(get_toolkit_secret prometheus.url)"
    echo
    echo "Grafana: $(get_toolkit_secret kubeprometheus_grafana.url)"
    echo "Username: $(get_toolkit_secret kubeprometheus_grafana.username)"
    echo "Password: $(get_toolkit_secret kubeprometheus_grafana.password)"
    echo
    echo "--------------------------------------------------------------------------------"
    # echo
    # echo -e "\e[1;34mHELLO WORLD APPLICATION\e[0m"
    # echo
    # echo "Hello, Devs! (development)"
    # echo "http://dev.localhost/hello"
    # echo "http://dev.localhost/hello/healthz"
    # echo
    # echo "Hello, QA Folks! (staging)"
    # echo "http://stg.localhost/hello"
    # echo "http://stg.localhost/hello/healthz"
    # echo
    # echo "Hello, Users! (production)"
    # echo "http://hello.localhost"
    # echo "http://hello.localhost/healthz"
    # echo
    # echo "--------------------------------------------------------------------------------"
}

get_toolkit_secret() {
    jq --raw-output .${1} toolkit-secrets.json
}

__main__
