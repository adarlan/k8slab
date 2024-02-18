import os
import random

import _logging
import _requests
import _name_generator

logger = _logging.logger

ITEM_CREATOR_URL = os.environ.get('ITEM_CREATOR_URL', 'http://localhost:8011')

item_count = random.randint(1, 100)
logger.info(f'Creating {item_count} items')

for i in range(0, item_count):
    item = {
        'name': _name_generator.generate_random_name()
    }
    response = _requests.post(ITEM_CREATOR_URL, item)
