#!/bin/bash
set -e

echo "Destroying local environment"
export TF_LOG=INFO
terraform destroy
