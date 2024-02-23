import re
from flask import request, jsonify

from _logging import logger
from _database import create, DatabaseException
from _flask import app, serve

@app.route('/api/items', methods=['POST'])
def create_item():

    name = request.json.get('name')

    regex_pattern = r'^[a-zA-Z]{5,30}+$'
    if not bool(re.match(regex_pattern, name)):
        response = {'error': 'Invalid name'}
        logger.info('Received invalid name from client', name=name)
        return jsonify(response), 400

    item = {'name': name}

    try:
        create(item)
    except DatabaseException as e:
        response = {'error': 'Failed to create item'}
        logger.error('Failed to create item in database', item=item, error=e)
        return jsonify(response), 500

    response = {'message': 'Created item'}
    logger.info('Created item', item=item)
    return jsonify(response), 200

serve()
