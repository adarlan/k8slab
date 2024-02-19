#!/bin/bash
set -ex

export TF_LOG=INFO

terraform init
terraform apply -auto-approve -parallelism=1
