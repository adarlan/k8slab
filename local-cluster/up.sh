#!/bin/bash
set -e
source terraform-config.sh

terraform init

TF_LOG="INFO" terraform apply
