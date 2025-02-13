## Key configuration items

### Configuration files
/etc/postfix/main.cf : main smtp parameters
- HELO name: `$myhostname`
- Transport concept: incoming -> queue manager -> one of the following, defined in main.cf:
  - local (`$mydestination`)
    - delivers mail to `~/Maildir`
    - recognizes `user1@postfix.smtp.garden` and `user2@postfix.smtp.garden`
  - SMTP garden peers.  Files referenced for these respective variables:
    - `relay_domains` - `$relay_domains`, accepted SMTP garden peers
    - `transport_maps` - `$transport_maps`, routing rules to respective `relay_domains` hosts
    - `recipient_canonical` - `$recipient_canonical_maps`, short aliases for peers
  - fallback to smart host (`$relayhost`)
/etc/postfix/master.cf : "the supervisor that keeps an eye on the well-being of the Postfix mail system"
- SMTP chroot must be set to 'n'

TODO:
- [ ] Docker volumize home folders, for Maildir inspection
- [ ] Enable postfix logging to file (for now, use `docker logs -f`)
