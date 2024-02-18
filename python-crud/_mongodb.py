import pymongo
import os
import _logging

logger = _logging.logger
logger.info('Initializing MongoDB connection')

MONGO_URI = os.environ.get('MONGO_URI')
MONGO_DATABASE = os.environ.get('MONGO_DATABASE')

client = pymongo.MongoClient(MONGO_URI)
database = client[MONGO_DATABASE]
collection = database['items']
