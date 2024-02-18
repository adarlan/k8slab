import random
import string

def generate_random_name():
    length = random.randint(8, 16)
    name = ''.join(random.choice(string.ascii_letters) for _ in range(length))
    return name

if __name__ == "__main__":
    random_name = generate_random_name()
    print("Random name:", random_name)
