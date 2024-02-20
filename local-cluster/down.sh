#!/bin/bash
set -ex

./cluster-toolkit.sh plan-destroy \
&& ./cluster-toolkit.sh destroy-with-plan \
|| ./cluster-toolkit.sh force-destroy

./kind-cluster.sh plan-destroy \
&& ./kind-cluster.sh destroy-with-plan \
|| ./kind-cluster.sh force-destroy
