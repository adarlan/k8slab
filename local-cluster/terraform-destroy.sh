#!/bin/bash
set -e

export TF_LOG=INFO

terraform destroy -auto-approve
