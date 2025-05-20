## Key configuration items

- Targets:
  - Supports standard SMTP Garden targets: local (see Mailboxes, below), named peers, and fallback server.
  - Now supports both SMTP and LMTP next hops.
- Main file: `/usr/exim/configure`
  - Trimmed/edited version of https://github.com/Exim/exim/blob/master/src/src/configure.default
  - HELO name: `primary_hostname` (main configuration settings)
  - Transport pipeline: ACL allow -> mail router (local, docker network to SMTP or LMTP, or failover) -> respective mail transporter
- Other files: Used to ensure correct protocol (SMTP vs LMTP) is used for next hop.
  - `/etc/smtp-garden-domains` - list of SMTP servers in garden
  - `/etc/lmtp-garden-domains` - list of LMTP servers in garden
- Main documentation at: https://www.exim.org/exim-html-current/doc/html/spec_html/index.html
- Local logs in /var/spool/exim/log

## Mailboxes
- Two local mailboxes have been created, to serve as local delivery targets
  - Usernames are user1 and user2
  - Uses the Maildir directory format (~/Maildir/{cur, new, tmp})
  - Container `/home` is volumized and mapped to `exim/home/` on the host
  - Container start script manages filesystem permissions
