#!/bin/bash
set -e

__main__() {
    TF_VERSION="1.7.3"
    tfenv install $TF_VERSION
    tfenv use $TF_VERSION
}

__main__
