import re
from flask import jsonify

from _logging import logger
from _database import read_many_items, DatabaseException
from _flask import app, serve

@app.route('/api/items/<regex>', methods=['GET'])
def fetch_items(regex):

    try:
        regex_pattern = re.compile(regex)
    except (re.error, OverflowError, MemoryError) as e:
        response = {'error': 'Invalid regex'}
        logger.info('Received invalid regex from client', regex=regex, error=e, response=response)
        return jsonify(response), 400

    try:
        items = read_many_items(regex_pattern)
    except DatabaseException as e:
        response = {'error': 'Failed to fetch items'}
        logger.error('Failed to read items from database', regex=regex, error=e, response=response)
        return jsonify(response), 500

    fetched_count = len(items)

    message = 'Fetched items' if fetched_count > 0 else 'No items to fetch'
    response = {
        'message': message,
        'regex': regex,
        'fetched_count': fetched_count,
        'items': items
    }
    logger.info(message, regex=regex, fetched_count=fetched_count)
    return jsonify(response), 200

serve()
