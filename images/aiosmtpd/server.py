"""
aiosmtpd proxy with local user Maildirs

Version 2.0 - 20250408 mss
- delivers to local Maildirs
- async server handler and controller
- uses external config file

Version 1.1.1 20240730 mss
- flush to stdout more frequently

Version 1.1 - 20240725 mss
- uses __RELAYHOST__ convention
- captures signals from docker for faster exit
- sets HELO name

Version 1.0 - kb
"""


import asyncio
import os
import mailbox
import signal
import sys
import threading
import time
from aiosmtpd.controller import Controller
from aiosmtpd.handlers import Proxy
from aiosmtpd.smtp import Envelope
from email import message_from_bytes


""" CONFIG """
from config import *
keep_running = True # holdover, used if stop signal received prior to async setup

""" UTILITY """
def announce(str, **kwargs):
    global selfname # from config.py
    print(f"{selfname} {str}", **kwargs)
    sys.stdout.flush() # otherwise nothing is printed until shutdown

""" SIGNAL HANDLING """
def stop_handler(sig, frame):
    """ Note: This is only useful prior to server thread """
    global keep_running
    announce(f"TERM or INT received.  Aborting...")
    sys.stdout.flush()
    keep_running = False

""" CLASSES """
class GardenHandler:
    """ Delivers local emails to local Maildirs, and proxies all other emails """
    """ Note: The ruleset for allowable characters in email addresses is complex,
        and no attempt is made here to be comprehensive. May yield false positive
        testing results. """
        
    def __init__(self, proxy_handler, local_users=None, host_aliases="localhost"):
        self.proxy_handler = proxy_handler
        self.local_users = local_users or []
        self.host_aliases = host_aliases

    async def handle_RCPT(self, server, session, envelope, address, rcpt_options):
        envelope.rcpt_tos.append(address)
        return '250 OK'

    def split_rcpt(self, rcpt):
        atn = rcpt.count('@')
        if atn == 0:
            return rcpt, None
        if atn == 1:
            return rcpt.split('@')
        return None, None

    def is_local(self, rcpt):
        """ Doesn't check validity of local usernames, just checks whether
        The address is intended to be local. """
        u,d = self.split_rcpt(rcpt)
        if u == None or u == '':
            return False        # Nonexistent username
        if d == None or d == '':
            return True         # Empty domain, assume local
        if d in self.host_aliases:
            return True         # Explicit host alias match
        return False            # Everything else

    def is_remote(self, rcpt):
        u,d = self.split_rcpt(rcpt)
        if u == None or u == '':
            return False        # Nonexistent username
        if d == None or d == '':
            return False        # Empty domain, assume local
        if d in self.host_aliases:
            return False        # Explicit host alias match
        return True             # Everything else

    async def handle_DATA(self, server, session, envelope):
        local_recipients = [rcpt for rcpt in envelope.rcpt_tos
                           if self.is_local( rcpt.lower() )]

        if not local_recipients:
            return await self.proxy_handler.handle_DATA(server, session, envelope)
        
        message = message_from_bytes(envelope.content)
        for recipient in local_recipients:

            user,discard = self.split_rcpt(recipient)
            user_maildir = os.path.expanduser(f"~{user}/Maildir")
            if not os.path.exists(user_maildir):
                announce(f"Warning: Maildir path {user_maildir} for user '{user}' does not exist. Skipping.")
                continue
            try:
                mdir = mailbox.Maildir(user_maildir)
                mdir.add(message)
                announce(f"Saved message for {recipient} in {user_maildir}")
            except OSError as e:
                announce(f"Can't access Maildir '{user_mailidir}' for user '{user}': {e}")

        external_recipients = [rcpt for rcpt in envelope.rcpt_tos 
                              if self.is_remote( rcpt.lower() )]
        if external_recipients:
            new_envelope = Envelope()
            new_envelope.mail_from = envelope.mail_from
            new_envelope.rcpt_tos = external_recipients
            new_envelope.content = envelope.content
            return await self.proxy_handler.handle_DATA(server, session, new_envelope)
        return '250 Message accepted for delivery'

class GardenSMTPServerThread(threading.Thread):
    """ Starts & runs the actual SMTP controller """
    def __init__(self, local_users, host_aliases, proxy_handler, host, port, **controller_kwargs):
        super().__init__(daemon=True)
        self.local_users = local_users
        self.host_aliases = host_aliases
        self.proxy_handler = proxy_handler
        self.host = host
        self.port = port
        self.controller_kwargs = controller_kwargs

        self.controller = None
        self.running = False
        self.ready_event = threading.Event()
        self.stop_event = threading.Event()

    def run(self):
        #global keep_running
        handler = GardenHandler(self.proxy_handler, self.local_users, self.host_aliases)

        loop = asyncio.new_event_loop()
        asyncio.set_event_loop(loop)

        controller_kwargs = {
            'hostname': self.host,
            'port': self.port,
            **self.controller_kwargs
        }

        self.controller = Controller(handler, **controller_kwargs) 
        self.controller.start()
        self.running = True

        announce(f"SMTP running on {self.host}:{self.port} for proxy transport and local delivery")
        self.ready_event.set()

        while self.running and not self.stop_event.is_set():
            time.sleep(0.5)
        announce("SMTP run method finishing...")
        #if self.controller:
        #    self.controller.stop()
        #self.running = False

    def stop(self, *kwargs):
        self.stop_event.set()
        if self.controller:
            announce("Stopping Controller...")
            self.controller.stop()
        self.running = False
        announce("SMTP Server stopped.")

""" RUN PROXY """
if __name__ == '__main__':
    signal.signal(signal.SIGINT, stop_handler)
    signal.signal(signal.SIGTERM, stop_handler)
    announce("Starting proxy...")

    smtp_thread = GardenSMTPServerThread(local_users,
                                         host_aliases,
                                         Proxy(relay_host, 25),
                                         "0.0.0.0", 25,
                                         server_hostname=HELO_name)
    smtp_thread.start()
    signal.signal(signal.SIGINT, smtp_thread.stop)
    signal.signal(signal.SIGTERM, smtp_thread.stop)
    smtp_thread.ready_event.wait()

    while smtp_thread.running:
        time.sleep(1)

    if smtp_thread:
        announce("Joining Server Thread...")
        smtp_thread.join(timeout=5)
    announce("Finished.")
