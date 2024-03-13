import requests
import _utils
from _logging import logger
from _env import ITEM_READER_URL

batch_size = _utils.random_batch_size()

for i in range(0, batch_size):
    iteration = str(i+1) + '/' + str(batch_size)
    regex = _utils.random_regex()
    url = ITEM_READER_URL + '/' + _utils.encoded_regex(regex)

    response = requests.get(url)
    try:
        response.raise_for_status()
        logger.info('Request to fetch items succeeded',
            iteration=iteration,
            regex=regex,
            url=url,
            response_status=response.status_code,
            response_data=response.json())
        # TODO do not log the entire response

    except requests.exceptions.RequestException as e:
        logger.error('Request to fetch items failed',
            iteration=iteration,
            regex=regex,
            url=url,
            response_status=response.status_code,
            error=e)
