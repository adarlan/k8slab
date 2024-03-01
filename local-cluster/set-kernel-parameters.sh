#!/bin/bash
set -e

(
    default_value=$(sysctl fs.inotify.max_user_instances | awk '{print $3}')
    new_value=1024
    echo "Setting fs.inotify.max_user_instances from $default_value to $new_value."
    # This is because some Grafana Agent and Promtail containers were crashing due to 'too many open files'.
    # Since both host and containers share the same kernel, setting it on the host applies to containers as well.
    # This value is reset when the system restarts.
    set -ex
    sudo sysctl -w fs.inotify.max_user_instances=$new_value
)
