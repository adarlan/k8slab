#!/bin/bash
set -e

cd local-environment

echo "Destroying local environment"
export TF_LOG=INFO
terraform destroy -auto-approve
