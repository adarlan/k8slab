#!/bin/bash
set -ex

kubectl describe namespace dev

kubectl describe role developer -n dev
kubectl describe clusterrole administrator

kubectl describe csr janeops
kubectl describe csr johndev

kubectl describe rolebinding johndev-developer -n dev
kubectl describe clusterrolebinding janeops-administrator

kubectl config view
