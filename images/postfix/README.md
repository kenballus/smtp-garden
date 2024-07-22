## Key configuration items

- Main files:
  - /etc/postfix/main.cf : main smtp parameters
  - /etc/postfix/master.cf : chroot must be set to 'n'
- HELO name: `myhostname` (main.cf)
- Target relay host: `relayhost` (main.cf)
