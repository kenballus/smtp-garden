## Dovecot (Submission service only)
__Exploratory image, may not be sustained.__  This server is Dovecot, but only the submission service is activated.  Proxies all email to `__RELAYHOST__`.  No LMTP or local inbox support.  See `dovecot` image for LMTP configuration.
- This server is mostly offered to have an alternative to the `dovecot` image for listening on a different default port (i.e., '25')

## Key configuration items
Main config files are in `usr/local/etc/dovecot`
- `dovecot.conf` is installed as a stand-alone config file, but Dovecat will also scan `conf.d/`, if present.
- See Submission Server section below for details.
- The latest (a/o 2025-03-03) Dovecot documentation updates are at: <https://doc.dovecot.org/2.4.0/installation/upgrade/2.3-to-2.4.html>
- Numerous breaking changes from 2.3 to 2.4, please report any unexpected behavior.
 
## Email Submission Server (SMTP-like)
- `submission_relay_host` is the name of the MTA to which Dovecot will try to deliver submission mail it receives on port 587
- The Dovecot 2.4 documentation reminds: ["DANGER: Dovecot's submission server is NOT a full-featured SMTP server. It REQUIRES proxying to an external relay SMTP submission server to deliver non-local messages."](https://doc.dovecot.org/2.4.0/core/config/submission.html)
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

