import re
from flask import request, jsonify

from _logging import logger
from _database import update_many_items, DatabaseException
from _flask import app, serve

@app.route('/api/items/<regex>', methods=['PUT'])
def update_item(regex):

    name = request.json.get('name')
    validation_pattern = r'^[a-zA-Z]{5,30}+$'
    if not bool(re.match(validation_pattern, name)):
        response = {'error': 'Invalid name'}
        logger.info('Received invalid name from client', name=name)
        return jsonify(response), 400

    try:
        regex_pattern = re.compile(regex)
    except (re.error, OverflowError, MemoryError) as e:
        response = {'error': 'Invalid regex'}
        logger.info('Received invalid regex from client', regex=regex, error=e, response=response)
        return jsonify(response), 400

    try:
        updated_count = update_many_items(regex_pattern, name)
    except DatabaseException as e:
        response = {'error': 'Failed to update items'}
        logger.error('Failed to update items in database', regex=regex, name=name, error=e, response=response)
        return jsonify(response), 500

    message = 'Updated items' if updated_count > 0 else 'No items to update'
    response = {
        'message': message,
        'regex': regex,
        'name': name,
        'updated_count': updated_count
    }
    logger.info(message, regex=regex, name=name, updated_count=updated_count)
    return jsonify(response), 200

serve()
