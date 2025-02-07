## Key configuration items

- IN PROGRESS: Maildir delivery configuration incomplete
- Main file: `/usr/exim/configure`
  - Trimmed/edited version of https://github.com/Exim/exim/blob/master/src/src/configure.default
- Transport pipeline: ACL allow -> mail router (local, docker network, or failover) -> respective mail transporter
- HELO name: `primary_hostname` (main configuration settings)
- Target relay host:
  - accepts mail to valid local users
  - relays mail other docker network hosts
    - Exim will fallback to A/AAAA records if no MX record found
    - Therefore, does not depend on a dns-mx container
  - fallback relay to `ROUTER_RELAY_HOST` (in main configuration settings)
- Main documentation at: https://www.exim.org/exim-html-current/doc/html/spec_html/index.html
- Local logs in /var/spool/exim/log
