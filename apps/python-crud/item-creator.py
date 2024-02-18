import flask
import waitress
import os

import _mongodb
import _logging
import _metrics

logger = _logging.logger

logger.info('Initializing Flask application')
app = flask.Flask(__name__)

@app.route('/', methods=['POST'])
@_metrics.REQUEST_LATENCY.time()
def createItem():

    itemName = flask.request.json.get('name')

    if not itemName:
        return flask.jsonify({'error': 'Item name is required'}), 400

    document = {'name': itemName}

    try:
        insertResult = _mongodb.collection.insert_one(document)
    except Exception as e:
        logger.error(f'Failed to create item: {document!r}; {e}')
        return flask.jsonify({'error': 'Failed to create item'}), 500

    if insertResult.inserted_id:
        logger.info(f'Item created successfully: {document!r}')
        return flask.jsonify({'message': 'Item created successfully'}), 200
    else:
        logger.error(f'Item not created: {document!r}')
        return flask.jsonify({'error': 'Item not created'}), 500

@app.route('/healthz')
def healthCheck():
    try:
        _mongodb.database.command('ping')
        return flask.jsonify({'message': 'Healthy'}), 200
    except Exception as e:
        logger.error(f'Health check failed: {e}')
        return flask.jsonify({'error': 'Unhealthy'}), 500

_metrics.start_metrics_server()

APP_PORT = int(os.environ.get('APP_PORT'))
logger.info(f'Serving Flask application with Waitress server on port {APP_PORT}')
waitress.serve(app, host='0.0.0.0', port=APP_PORT)
