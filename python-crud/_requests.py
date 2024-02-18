import requests

import _logging

logger = _logging.logger

def post(url, data):
    logger.info('Sending POST request')
    logger.info('URL: {url}')
    logger.info('Data: {data}')
    try:
        response = requests.post(url, json=data)
        response.raise_for_status()
        logger.info('POST request successful!')
        logger.info('Response: {response.text}')
        return response.json
    except requests.exceptions.RequestException as e:
        logger.error('Error: {e}')
