#!/bin/bash
set -ex

kubectl describe namespace dev
kubectl describe role developer -n dev

kubectl describe clusterrole administrator

kubectl describe csr janeops
kubectl describe csr johndev

kubectl describe rolebinding developer-johndev -n dev
kubectl describe clusterrolebinding administrator-janeops -n dev

kubectl config view
