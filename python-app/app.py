import flask
import waitress
import prometheus_client
import random
import time

app = flask.Flask(__name__)

REQUEST_LATENCY = prometheus_client.Summary('request_latency_seconds', 'Request latency in seconds')

@app.route('/')
@REQUEST_LATENCY.time()
def handle_request():
    random_sleep_time = random.uniform(0.1, 0.9)
    time.sleep(random_sleep_time)
    return f'Hello, this is a simple Python application! Random sleep time: {random_sleep_time:.2f} seconds.'

if __name__ == "__main__":
    prometheus_client.start_http_server(8000)
    waitress.serve(app, host="0.0.0.0", port=80)
