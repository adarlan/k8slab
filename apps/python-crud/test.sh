#!/bin/sh
set -e

create_item() {
    curl -X POST -H "Content-Type: application/json" -d '{"name":"${1}"}' http://localhost:8011
}

health_check() {
    curl -X GET http://localhost:8011/healthz
}

health_check
create_item "Foo"
health_check
create_item "Bar"
health_check
