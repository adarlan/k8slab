import re
from flask import jsonify

from _logging import logger
from _database import delete, DatabaseException
from _flask import app, serve

@app.route('/api/items/<regex>', methods=['DELETE'])
def delete_items(regex):

    try:
        regex_pattern = re.compile(regex)
    except (re.error, OverflowError, MemoryError) as e:
        response = {'error': 'Invalid regex'}
        logger.info('Received invalid regex from client', regex=regex, error=e, response=response)
        return jsonify(response), 400

    try:
        deleted_count = delete(regex_pattern)
    except DatabaseException as e:
        response = {'error': 'Failed to delete items'}
        logger.error('Failed to delete items from database', regex=regex, error=e, response=response)
        return jsonify(response), 500

    message = 'Deleted items' if deleted_count > 0 else 'No items to delete'
    response = {
        'message': message,
        'regex': regex,
        'deleted_count': deleted_count
    }
    logger.info(message, regex=regex, deleted_count=deleted_count)
    return jsonify(response), 200

serve()
