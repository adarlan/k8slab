#!/bin/bash
set -e

echo "\nDestroying local environment"
export TF_LOG=INFO
terraform destroy
