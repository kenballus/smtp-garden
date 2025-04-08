"""
Configuration file for aiosmtpd server.py
"""

# Console ID string
# Token that precedes all information printed to stdout
selfname = "[aiosmtpd]"

# HELO name
HELO_name = "aiostmpd.smtp.garden"

# Relay server
# Replace __RELAYHOST__ with smarthost name for all non-local email.
relay_host = "__RELAYHOST__"

# Local user accounts
# Please ensure /home/{user}/Maildir/{new|cur|temp} exist.
local_users = ['user1', 'user2']

# Local domain aliases
# Ensure consistency with Docker networking and container hostname assignment.
host_aliases = ['localhost', 'aiosmtpd', 'aiosmtpd.smtp.garden', '127.0.0.1']

# End config.py
