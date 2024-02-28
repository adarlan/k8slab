import pymongo
import time

from _env import MONGO_URI, MONGO_DATABASE
from _logging import logger
import _metrics

logger.debug('Connecting to MongoDB', database=MONGO_DATABASE)
try:
    mongo_client = pymongo.MongoClient(MONGO_URI)
    mongo_database = mongo_client[MONGO_DATABASE]
    collection = mongo_database['items']
    _metrics.items_total.set(collection.count_documents({}))
except pymongo.errors.PyMongoError as e:
    logger.error('Failed to connect to MongoDb', database=MONGO_DATABASE, error=e)
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

def create_one_item(item):

    document = item.copy()
    start_time = time.time()

    try:
        collection.insert_one(document)
    except pymongo.errors.PyMongoError as e:
        raise DatabaseException('Failed to insert document in MongoDB collection', e)

    _metrics.database_latency_seconds.labels(
        operation='create_one_item'
        ).observe(time.time() - start_time)

    _metrics.items_total.inc(1)

def read_many_items(pattern):

    filter_query = {"name": {"$regex": pattern}}
    items = []
    start_time = time.time()

    try:
        result = collection.find(filter_query)
    except pymongo.errors.PyMongoError as e:
        raise DatabaseException('Failed to find documents in MongoDB collection', e)

    _metrics.database_latency_seconds.labels(
        operation='read_many_items'
        ).observe(time.time() - start_time)

    for document in result:
        item = document.copy()
        del item['_id']
        items.append(item)

    return items

def update_many_items(pattern, name):

    filter_query = {"name": {"$regex": pattern}}
    update_query = {'$set': {'name': name}}
    start_time = time.time()

    try:
        result = collection.update_many(
            filter=filter_query,
            update=update_query)
    except pymongo.errors.PyMongoError as e:
        raise DatabaseException('Failed to update documents in MongoDB collection', e)

    _metrics.database_latency_seconds.labels(
        operation='update_many_items'
        ).observe(time.time() - start_time)

    return result.matched_count

def delete_many_items(pattern) -> int:

    filter_query = {"name": {"$regex": pattern}}
    start_time = time.time()

    try:
        result = collection.delete_many(filter_query)
    except pymongo.errors.PyMongoError as e:
        raise DatabaseException('Failed to delete documents in MongoDB collection', e)

    _metrics.database_latency_seconds.labels(
        operation='delete_many_items'
        ).observe(time.time() - start_time)

    _metrics.items_total.dec(result.deleted_count)

    return result.deleted_count
