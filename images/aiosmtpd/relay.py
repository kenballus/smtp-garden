import time

from aiosmtpd.handlers import Proxy
from aiosmtpd.controller import Controller

controller = Controller(Proxy("echo", 25), "0.0.0.0", 25)
controller.start()
while True:
    time.sleep(65535)
