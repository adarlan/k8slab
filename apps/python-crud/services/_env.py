import os
import logging

APP_ENVIRONMENT = os.environ.get(
    'APP_ENVIRONMENT',
    'development')

LOG_LEVEL = logging._nameToLevel[os.environ.get(
    'LOG_LEVEL',
    'DEBUG')]

APP_PORT = int(os.environ.get(
    'APP_PORT',
    '8080'))

METRICS_PORT = int(os.environ.get(
    'METRICS_PORT',
    '9100'))

MONGO_URI = os.environ.get(
    'MONGO_URI',
    'mongodb://{username}:{password}@{host}:{port}/'.format(
        username = os.environ.get('MONGO_USERNAME', 'root'),
        password = os.environ.get('MONGO_PASSWORD', 'example'),
        host     = os.environ.get('MONGO_HOST',     'localhost'),
        port     = os.environ.get('MONGO_PORT',     '27017')
    )
)

MONGO_DATABASE = os.environ.get(
    'MONGO_DATABASE',
    'default')
