import logging
import os

logger = logging.getLogger()

LOG_LEVEL = os.environ.get('LOG_LEVEL')
logger.setLevel(logging.DEBUG)

LOG_FORMAT = os.environ.get('LOG_FORMAT')
formatter = logging.Formatter(LOG_FORMAT)

streamHandler = logging.StreamHandler()
streamHandler.setFormatter(formatter)

logger.addHandler(streamHandler)
