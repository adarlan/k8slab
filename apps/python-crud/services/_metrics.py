from prometheus_client import Counter, Summary

received_requests          = Counter('received_requests',           'Number of requests received')
successful_requests        = Counter('successful_requests',         'Number of requests processed successfully')
failed_requests            = Counter('failed_requests',             'Number of failed attempts to process a request')
bad_requests               = Counter('bad_requests',                'Number of client malformed requests')
request_latency_in_seconds = Summary('request_latency_in_seconds',  'Request latency in seconds')
database_latency_seconds   = Summary('database_latency_seconds', 'Database latency in seconds')
