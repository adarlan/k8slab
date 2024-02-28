from prometheus_client import Gauge, Counter, Summary

items_total = Gauge(
    'pycrud_items_total',
    'Current number of items')

http_requests_total = Counter(
    'pycrud_http_requests_total',
    'Number of HTTP requests',
    ['method', 'status'])

http_request_duration_seconds = Summary(
    'pycrud_http_request_duration_seconds',
    'HTTP request duration in seconds',
    ['method', 'status'])

database_latency_seconds = Summary(
    'pycrud_database_latency_seconds',
    'Database latency in seconds',
    ['operation'])
