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
    request.start_time = time.time()

@app.after_request
def after_request(response):
    if not request.path == '/healthz':

        _metrics.http_request_duration_seconds.labels(
            method=request.method,
            status=response.status_code
        ).observe(time.time() - request.start_time)

        _metrics.http_requests_total.labels(
            method=request.method,
            status=response.status_code
        ).inc()

    return response

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
