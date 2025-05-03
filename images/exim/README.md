## Key configuration items

- Main file: `/usr/exim/configure`
  - Trimmed/edited version of https://github.com/Exim/exim/blob/master/src/src/configure.default
- HELO name: `primary_hostname` (main configuration settings)
- Transport pipeline: ACL allow -> mail router (local, docker network, or failover) -> respective mail transporter
- Targets:
  - Local: accepts mail to valid local users.  Currently:
    - `user1` and `user2`, i.e. `user1@exim.smtp.garden`
    - emails saved in `/home/user{1|2}/Maildir/{new, tmp, cur}`
  - Docker network: relays mail other docker network hosts
    - Exim will fallback to A/AAAA records if no MX record found
    - Therefore, does not depend on a dns-mx container
  - Fallback: everything else (including generated bounce replies, etc) relay to `ROUTER_RELAY_HOST` (in main configuration settings)
- Main documentation at: https://www.exim.org/exim-html-current/doc/html/spec_html/index.html
- Local logs in /var/spool/exim/log

## Mailboxes
- Two local mailboxes have been created, to serve as local delivery targets
  - Usernames are user1 and user2
  - Uses the Maildir directory format (~/Maildir/{cur, new, tmp})
  - Container `/home` is volumized and mapped to `exim/home/` on the host
  - Container start script manages filesystem permissions

## TODO
- [ ] LMTP mailer
