import requests
import _utils
from _logging import logger
from _env import ITEM_CREATOR_URL

batch_size = _utils.random_batch_size()

for i in range(0, batch_size):
    iteration = str(i+1) + '/' + str(batch_size)
    url = ITEM_CREATOR_URL
    data = {'name': _utils.random_name()}

    response = requests.post(url, json=data)
    try:
        response.raise_for_status()
        logger.info('Request to create item succeeded',
            iteration=iteration,
            url=url,
            data=data,
            response_status=response.status_code,
            response_data=response.json())

    except requests.exceptions.RequestException as e:
        logger.error('Request to create item failed',
            iteration=iteration,
            url=url,
            data=data,
            response_status=response.status_code,
            error=e)
