## Key configuration items

Main config files are in `usr/local/etc/dovecot`
- `dovecot.conf` is installed as a stand-alone config file, but Dovecat will also scan `conf.d/`, if present.
- See Submission Server and LTMP Server sections below for details.
- The latest (a/o 2025-03-03) Dovecot documentation updates are at: <https://doc.dovecot.org/2.4.0/installation/upgrade/2.3-to-2.4.html>
  - Numerous breaking changes from 2.3 to 2.4, please report any unexpected behavior.

## Email Submission Server (SMTP-like)
- `submission_relay_host` is the name of the MTA to which Dovecot will try to deliver submission mail it receives on port 587
- The Dovecot 2.4 documentation reminds: ["DANGER: Dovecot's submission server is NOT a full-featured SMTP server. It REQUIRES proxying to an external relay SMTP submission server to deliver non-local messages."](https://doc.dovecot.org/2.4.0/core/config/submission.html)
  - In other words, Dovecot does not behave like the SMTP servers in the garden.  Messages sent to this listener will NOT go to a local Dovecot user Maildir folder unless you set `submission_relay_host` to `dovecot` or `dovecot.smtp.garden` and reference the appropriate port for the LMTP server.
  - You could, for instance, set `submission_relay_host` to one of the other SMTP servers in the garden, and configure that server to send Dovecot emails to the LMTP server.
  - Otherwise, bypass the submission/SMTP servers and use the LMTP server directly (see below) whose job it is to do exactly that (for local emails only).
- Authentication is required.  It has been configured as permissively as possible.
  - Authenticate with a valid system user (i.e., `user1` or `user2`)
  - Any password entered will be accepted (but it still needs to be a valid base64 encoding).
  - see <https://doc.dovecot.org/2.3/admin_manual/debugging/debugging_authentication/>
  - You can use the one-liner, `AUTH PLAIN dXNlcjEAdXNlcjEAdXNlcjE=\n`, or, the AUTH LOGIN conversation (see below)
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

## LMTP Server (for local inboxes)
- Dovecot also listens on port 24 to provide LMTP services to local mailboxes.
- No authentication required, but Dovecot will only deliver to a local user with a valid ~/Maildir tree.
- This server strips the domain from the email address (i.e. `user1@anything.smtp.garden` or even `user1@example.org` become `user1` and get delivered locally)
- Two local mailboxes have been created, to serve as local delivery targets
  - Usernames are `user1` and `user2`
  - Uses the Maildir++ directory format (~/Maildir/{cur, new, tmp})
  - Container `/home` is volumized and mapped to `dovecot/home/` on the host
  - Container start script manages filesystem permissions

