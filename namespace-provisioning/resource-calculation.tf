# variable "namespaces" {
#   type    = list(map)
#   default = []
# }

# locals {
#   namespaces = [
#     for namespace in var.namespaces : {

#       containers_per_pod = coalesce(
#         namespace.containers_per_pod,
#         1
#       )

#       max_container_count_based_on_cpu = coalesce(
#         namespace.max_container_count_based_on_cpu,
#         try(namespace.cpu_requests_quota / namespace.default_cpu_request_per_container, null)
#       )

#     }
#   ]
# }

/*
Each property has many forms of calculation.
The first one is when its value is explicitly defined.
Then try each other until one succeeds, that is, if the properties involved in the calculation are set.
The last one is to use the standard value.

## containers_per_pod

- 1

## max_container_count_based_on_cpu

- cpu_requests_quota / default_cpu_request_per_container
- 10

## max_container_count_based_on_memory

- memory_requests_quota / default_memory_request_per_container
- 20

## max_pod_count

- containers_per_pod * min(max_container_count_based_on_cpu, max_container_count_based_on_memory)
- 20

## cpu_requests_quota

- max_pod_count * default_cpu_request_per_container
- 2000

## default_cpu_request_per_container

- cpu_requests_quota / max_pod_count
- 100

## min_cpu_request_per_container

- default_cpu_request_per_container / 2 (???)
- 50

## cpu_limit_ratio

- cpu_limits_quota
- 2

*/
