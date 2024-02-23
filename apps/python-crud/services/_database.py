import pymongo
import time

from _env import MONGO_URI, MONGO_DATABASE
from _logging import logger
from _metrics import database_latency_seconds

logger.debug('Connecting to MongoDB', uri='[SENSITIVE]', database=MONGO_DATABASE)
try:
    mongo_client = pymongo.MongoClient(MONGO_URI)
    mongo_database = mongo_client[MONGO_DATABASE]
    collection = mongo_database['items']
except pymongo.errors.PyMongoError as e:
    logger.error('Failed to connect to MongoDb', uri='[SENSITIVE]', database=MONGO_DATABASE, error=e)
    raise e

class DatabaseException(Exception):
    def __init__(self, message, original_exception):
        super().__init__(message)
        self.original_exception = original_exception
    def __str__(self):
        return f"{super().__str__()}\nOriginal Exception: {str(self.original_exception)}"

def ping():
    try:
        mongo_database.command('ping')
    except pymongo.errors.PyMongoError as e:
        raise DatabaseException('Failed to ping MongoDB', e)

def create(item):
    document = item.copy()
    try:
        start_time = time.time()
        collection.insert_one(document)
        database_latency_seconds.observe(time.time() - start_time)
    except pymongo.errors.PyMongoError as e:
        raise DatabaseException('Failed to insert document in MongoDB collection', e)

def read(pattern):
    items = []
    try:
        start_time = time.time()
        result = collection.find({"name": {"$regex": pattern}})
        database_latency_seconds.observe(time.time() - start_time)
    except pymongo.errors.PyMongoError as e:
        raise DatabaseException('Failed to find documents in MongoDB collection', e)
    for document in result:
        item = document.copy()
        del item['_id']
        items.append(item)
    return items

def update(pattern, name):
    filter_query = {"name": {"$regex": pattern}}
    update_query = {'$set': {'name': name}}
    try:
        start_time = time.time()
        result = collection.update_many(
            filter=filter_query,
            update=update_query
        )
        database_latency_seconds.observe(time.time() - start_time)
    except pymongo.errors.PyMongoError as e:
        raise DatabaseException('Failed to update documents in MongoDB collection', e)
    return result.matched_count

def delete(pattern) -> int:
    try:
        start_time = time.time()
        result = collection.delete_many({"name": {"$regex": pattern}})
        database_latency_seconds.observe(time.time() - start_time)
    except pymongo.errors.PyMongoError as e:
        raise DatabaseException('Failed to delete documents in MongoDB collection', e)
    return result.deleted_count
