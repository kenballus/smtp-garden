"""
aiosmtpd proxy

Version 1.1.1 20240730 mss
- flush to stdout more frequently

Version 1.1 - 20240725 mss
- uses __RELAYHOST__ convention
- captures signals from docker for faster exit
- sets HELO name

Version 1.0 - kb
"""

import signal
import sys
import time

from aiosmtpd.handlers import Proxy
from aiosmtpd.controller import Controller

""" GLOBALS """
# replace __RELAYHOST__ with SMTP target
relay_host = "__RELAYHOST__"
keep_running = True
HELO_name = "smtp-garden-aiostmpd"


""" SIGNAL HANDLING """
def stop_handler(sig, frame):
    global keep_running
    print(f"[aiosmtpd] Exiting...", end="")
    sys.stdout.flush()
    keep_running = False

signal.signal(signal.SIGINT, stop_handler)
signal.signal(signal.SIGTERM, stop_handler)


""" RUN PROXY """
controller = Controller(
    Proxy(relay_host, 25), "0.0.0.0", 25, server_hostname=HELO_name
)

print("[aiosmtpd] Starting proxy...")
sys.stdout.flush()
controller.start()
while keep_running:
    time.sleep(1)
controller.stop(True)
print("Bye")
sys.stdout.flush()
