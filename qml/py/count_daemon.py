import os
import sys
import time

from daemon import Daemon
from harbour_countdown import *

class TDaemon(Daemon):
    def __init__(self, *args, **kwargs):
        pass
    def run(self):
        mymain()

def control_daemon(action):
    os.system(" ".join((sys.executable, __file__, action)))

if __name__ == '__main__':
    if len(sys.argv) == 1:
        sys.exit(1)
    elif len(sys.argv) == 2:
        arg = sys.argv[1]
        if arg in ('start', 'stop', 'restart'):
            d = TDaemon('/var/tmp/python-daemon.pid', verbose=0)
            getattr(d, arg)()
