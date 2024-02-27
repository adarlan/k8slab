#!/bin/bash
set -e

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
    echo "Argo CD: $(info_value kind-toolkit argocd.url)"
    echo "Username: $(info_value kind-toolkit argocd.username)"
    echo "Password: $(info_value kind-toolkit argocd.password)"
    echo
    echo "Prometheus: $(info_value kind-toolkit prometheus.url)"
    echo
    echo "Grafana: $(info_value kind-toolkit kubeprometheus_grafana.url)"
    echo "Username: $(info_value kind-toolkit kubeprometheus_grafana.username)"
    echo "Password: $(info_value kind-toolkit kubeprometheus_grafana.password)"
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

info_value() {
    jq --raw-output .info.value.${2} ${1}-output.json
}

info
