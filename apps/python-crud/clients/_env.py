import os
import logging

APP_ENVIRONMENT = os.environ.get(
    'APP_ENVIRONMENT',
    'development')

LOG_LEVEL = logging._nameToLevel[os.environ.get(
    'LOG_LEVEL',
    'DEBUG')]

ITEM_CREATOR_URL = os.environ.get('API_URL', 'http://localhost:8011/api/items')
ITEM_READER_URL  = os.environ.get('API_URL', 'http://localhost:8021/api/items')
ITEM_UPDATER_URL = os.environ.get('API_URL', 'http://localhost:8031/api/items')
ITEM_DELETER_URL = os.environ.get('API_URL', 'http://localhost:8041/api/items')

MIN_ITERATIONS = int(os.environ.get('MIN_ITERATIONS', '1'))
MAX_ITERATIONS = int(os.environ.get('MAX_ITERATIONS', '10'))
