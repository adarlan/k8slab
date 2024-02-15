#!/bin/bash
set -e

export TF_LOG=INFO

terraform init
terraform apply -auto-approve
