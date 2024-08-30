## Key configuration items

- Main files:
  - /etc/postfix/main.cf : main smtp parameters
  - /etc/postfix/master.cf : chroot must be set to 'n'
- HELO name: `myhostname` (main.cf)
- Target relay host: `relayhost` (main.cf)

## Versions

Two versions are provided.  They require different configuration methods, see Dockerfiles.
- Default version: Built from source
- Alternate: Installed from repo
