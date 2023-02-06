import os
import jurigged
# jurigged.watch()

import logging
import time
log = logging.getLogger(__name__)
log.setLevel('INFO')

import gevent
from flask import Flask
# from flask_sock import Sock
from flask import request
from flask_caching import Cache


config = {
    "DEBUG": True,
    "CACHE_TYPE": "FileSystemCache",
    "CACHE_DEFAULT_TIMEOUT": 60,
    "CACHE_DIR": "/tmp/flask-cache-666",
}

app = Flask(__name__)
# sock = Sock(app)
app.config.from_mapping(config)
cache = Cache(app)


@app.route('/')
def index():
    return "ok"


LONG_POLLING_TIMEOUT = 30


@cache.cached(timeout=1)
def file_timestamps(root_dir):
    log.info('re-evaluating files at %s ...', root_dir)
    for root, dirs, files in os.walk(root_dir, topdown=False):
        for name in files:
            path = os.path.join(root, name)
            rel = os.path.relpath(path, root_dir)
            yield {
                "path": rel,
                "mtime": os.stat(path).st_mtime,
            }


def _filter_timestamps(app_name, since):
    return [
        d for d in file_timestamps(app_name)
        if d["mtime"] > since
    ]


def _get_changed_code_files(app_name, since=None):
    rv = {}
    if since:
        t0 = time.time()
        rv["timestamps"] = []
        while time.time() < t0 + LONG_POLLING_TIMEOUT:
            rv["timestamps"] = _filter_timestamps(app_name, since)
            if rv["timestamps"]:
                break
            gevent.sleep(1)
    rv["now"] = time.time()
    return rv

# @sock.route('/ws/has-code-changed')
# def ws_has_code_changed(sock):
#     while True:
#         data = sock.receive()
#         log.info('sock recv ' + str(data))
#         sock.send(_get_changed_code_files(str(data).strip()))
#         gevent.sleep()


@app.route('/http/has-code-changed')
def http_has_code_changed():
    since =  request.args.get('since')
    app_name = request.args.get('app_name')
    if since:
        since = float(since)

    return _get_changed_code_files(os.path.join("src", app_name), since)