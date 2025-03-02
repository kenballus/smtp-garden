## Key configuration items

Main config files are in `usr/local/etc/dovecot`
- `dovecot.conf` is installed as a stand-alone config file, but Dovecat will also scan `conf.d/`, if present.
- See Submission Server and LTMP Server sections below for details.
- The latest (a/o 2024-09-16) Dovecot documentation is at: <https://doc.dovecot.org/2.3/configuration_manual/>, which is rather thorough, with some caveats:
  - Examples provided show `userdb { ... }` and `passdb { ... }` but the latest version requires an arbitrary `name` namespace assignment in this format:
    - `userdb <name> { ... }`
    - Otherwise it will fail, and complain about an unlabeled namespace.  This does not seem to be explained well, and is contrary to many examples.

## Email Submission Server (SMTP-like)
- `submission_relay_host` is the name of the MTA to which Dovecot will try to deliver submission mail it receives on port 587
  - Messages sent to this listener will NOT go to a local Dovecot user Maildir folder unless you set `submission_relay_host` to `dovecot` or `dovecot.smtp.garden` and reference the appropriate port for the LMTP server.
  - If you want to send an email to a target local user, set `submission_relay_host` accordingly, or, use the LMTP server (see below) whose job it is to do exactly that.
- Authentication is required.  It has been configured as permissively as possible.
  - Authenticate with a valid system user (i.e., `user1` or `user2`)
  - Any password entered will be accepted (but it still needs to be a valid base64 encoding).
  - see <https://doc.dovecot.org/2.3/admin_manual/debugging/debugging_authentication/>
  - You can use `AUTH PLAIN dXNlcjEAdXNlcjEAdXNlcjE=\n`
    - The base64 string is just `user1\0user1\0user1` (\<userID\>\\0\<loginID\>\\0\<password\>)
  - Or, use `AUTH LOGIN dXNlcjE=` as such:
```
HELO vmail
250 smtp-garden-dovecot
AUTH LOGIN dXNlcjE=          # 'dXNlcjE=' is 'user1'
334 UGFzc3dvcmQ6
dXNlcjE=
235 2.7.0 Logged in.
```

## LMTP Server
- Dovecot also listens on port 24 to provide LMTP services to local mailboxes.
- No authentication required, but Dovecot will only deliver to a local user with a valid ~/Maildir tree.
- This server strips the domain from the email address (i.e. `user1@anything.smtp.garden` becomes `user1` and gets delivered locally)
- Two local mailboxes have been created, to serve as local delivery targets
  - Usernames are `user1` and `user2`
  - Uses the Maildir++ directory format (~/Maildir/{cur, new, tmp})

