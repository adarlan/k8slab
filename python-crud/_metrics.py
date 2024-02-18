import prometheus_client
import os
import _logging

logger = _logging.logger
logger.info('Initializing Prometheus metrics')

METRICS_PORT = int(os.environ.get('METRICS_PORT'))

REQUEST_LATENCY = prometheus_client.Summary('request_latency_seconds', 'Request latency in seconds')

def start_metrics_server():
    logger.info(f'Starting Prometheus metrics web server on port {METRICS_PORT}')
    prometheus_client.start_http_server(METRICS_PORT)
