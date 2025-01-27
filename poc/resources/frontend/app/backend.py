import os
import requests

URL = os.environ.get('BACKEND', 'http://127.0.0.1:8000')


def api_get(path):
    response = requests.get(f'{URL}/{path}')
    return response.json()
