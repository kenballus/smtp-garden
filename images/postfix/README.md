## Key configuration items

### Configuration files
- 5 files, deployed from `conf/`
  - main.cf
  - master.cf
  - recipient_canonical
  - relay_domains
  - transport
- Postfix stores them in `/etc/postfix/`
#### main.cf
- main smtp parameters
- HELO name: `$myhostname`
- Transport concept: incoming -> queue manager -> one of the following, defined in main.cf:
  - local (recipient matches `mydestination`)
    - delivers mail to `~/Maildir`
    - recognizes `user1@postfix.smtp.garden` and `user2@postfix.smtp.garden`
  - SMTP garden peers.  Aliases and routing defined in the other files, see below.
  - fallback to smart host (`$relayhost`)
#### master.cf
- "the supervisor that keeps an eye on the well-being of the Postfix mail system"
- SMTP and LMTP chroot must be set to 'n'
- Want more debug output? Add `-v` arg to the desired lines
#### Files referenced by main.cf:
- recipient_canonical
  - Aliases for garden peers
- relay_domains
  - Recognized SMTP Garden peers 
- transport
  - Routing table
  - Square brackets disable MX lookup, which will fail without an MX name server
  - Note `lmtp:inet` associated with LMTP destinations (i.e., dovecot)

## Mailboxes
- Two local mailboxes have been created, to serve as local delivery targets
  - Usernames are user1 and user2
  - Uses the Maildir directory format (~/Maildir/{cur, new, tmp})
  - Container `/home` is volumized and mapped to `postfix/home/` on the host
  - Container start script manages filesystem permissions

## Other
- Troubleshooting notes
  - `postconf -d` dumps config settings.
  - `postfix reload` will update config settings while Postfix is running.
  - You can run `mailq` in the container to see email in the queues
  - Postfix uses `syslog`, but inside acontainer it's not a great option.
  - Adding verbosity flag `-v` to lines in `master.cf` seems to interfere with routing

