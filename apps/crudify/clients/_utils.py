import random
import string
import os
from urllib.parse import quote

from _env import MIN_ITERATIONS, MAX_ITERATIONS

min_name_length = 2
max_name_length = 32

def random_batch_size():
    return random.randint(MIN_ITERATIONS, MAX_ITERATIONS)

def random_name_length():
    return random.randint(min_name_length, max_name_length)

def random_name():
    length = random_name_length()
    name = ''.join(random.choice(string.ascii_letters) for _ in range(length))
    return name

def random_regex():
    name_length = random_name_length()
    regex = '^[a-zA-Z]{' + str(name_length) + '}$'
    return regex

def encoded_regex(regex):
    return quote(regex)
