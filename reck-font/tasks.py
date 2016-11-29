# Start rabbitmq server: sudo rabbitmq-server -detached
# Stop rabbitmq with sudo rabbitmqctl stop
# Run this tasks file with:  celery -A tasks worker --concurrency=4
# Purge celery queeu celery -A tasks purge
# Info on monitoring: http://docs.celeryproject.org/en/latest/userguide/monitoring.html
from celery import Celery
import sys
import os
sys.path.append(os.getcwd())  # We need this so that when celery runs it sets the current working directory in the path
app = Celery('tasks', broker='amqp://guest@localhost//', backend='amqp://guest@localhost//')


@app.task
def run_analysis_algorithm(algorithm, sound):
    result = algorithm(sound)
    if result:
        print 'Analyzed sound %s with %s' % (unicode(sound['id']), algorithm.__name__)
    else:
        print 'Failed analyzing sound %s with %s' % (unicode(sound['id']), algorithm.__name__)
    return result
