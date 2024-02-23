from flask import Flask, request, jsonify
import prometheus_client
import time

from _env import APP_ENVIRONMENT, APP_PORT, METRICS_PORT
from _logging import logger
import _metrics

import _database as database
from _database import DatabaseException

app = Flask(__name__)

@app.before_request
def before_request():
    _metrics.received_requests.inc()
    request.start_time = time.time()

@app.after_request
def after_request(response):

    _metrics.request_latency_in_seconds.observe(time.time() - request.start_time)

    if response.status_code == 200:
        _metrics.successful_requests.inc()

    elif response.status_code == 400:
        _metrics.bad_requests.inc()

    elif response.status_code == 500:
        _metrics.failed_requests.inc()

    return response

# TODO how to prevent before_request and after_request being called for /healthz requests?

@app.route('/healthz')
def healthz():
    try:
        database.ping()
        response = {'message': 'Healthy'}
        return jsonify(response), 200
    except DatabaseException as e:
        response = {'error': 'Unhealthy'}
        logger.error('Health check failed', error=e, response=response)
        return jsonify(response), 500

def serve():

    logger.debug('Starting Prometheus metrics server', metrics_port=METRICS_PORT)
    prometheus_client.start_http_server(METRICS_PORT)

    if APP_ENVIRONMENT == 'development':
        logger.debug('Starting application with Flask server', app_port=APP_PORT)
        app.run(
            host='0.0.0.0',
            port=APP_PORT)

    else:
        logger.debug('Starting application with Waitress server', app_port=APP_PORT)
        app.debug = False
        import waitress
        waitress.serve(
            app,
            host='0.0.0.0',
            port=APP_PORT)
