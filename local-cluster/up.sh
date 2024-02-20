#!/bin/bash
set -ex

./kind-cluster.sh apply

./cluster-toolkit.sh apply
./cluster-toolkit.sh argocd-login
./cluster-toolkit.sh output-login-info
