import requests
import _utils
from _logging import logger
from _env import ITEM_UPDATER_URL

batch_size = _utils.random_batch_size()

for i in range(0, batch_size):
    iteration = str(i+1) + '/' + str(batch_size)
    regex = _utils.random_regex()
    url = ITEM_UPDATER_URL + '/' + _utils.encoded_regex(regex)
    data = {'name': _utils.random_name()}

    response = requests.put(url, json=data)
    try:
        response.raise_for_status()
        logger.info('Request to update items succeeded',
            iteration=iteration,
            regex=regex,
            url=url,
            data=data,
            response_status=response.status_code,
            response_data=response.json())

    except requests.exceptions.RequestException as e:
        logger.error('Request to update items failed',
            iteration=iteration,
            regex=regex,
            url=url,
            data=data,
            response_status=response.status_code,
            error=e)
