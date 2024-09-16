## Key configuration items

Main config files are in `usr/local/etc/dovecot`
- `dovecot.conf` is installed as a stand-alone config file, but Dovecat will also scan `conf.d/`, if present.
- See Submission Server and LTMP Server sections below for details.
- The latest (a/o 2024-09-16) Dovecot documentation is at: <https://doc.dovecot.org/2.3/configuration_manual/>, which is rather thorough, with some caveats:
  - Examples provided show `userdb { ... }` and `passdb { ... }` but the latest version requires an arbitrary `name` assignment in this format:
    - `userdb name { ... }`
    - Otherwise it will fail, and complain about an unlabeled namespace.  This is poorly documented.
  - The manual documents _most_ features well, but assumes you already have a general working familiarity with configuration.  Examples are often incomplete.

## Email Submission Server (SMTP-like)
- `submission_relay_host` is the name of the MTA to which Dovecot will try to deliver submission mail it receives on port 587
- Authentication is required.  It has been configured as permissively as possible.
  - Any password entered will be accepted (but it still needs to be a valid base64 encoding).
  - see <https://doc.dovecot.org/2.3/admin_manual/debugging/debugging_authentication/>
  - You can use `AUTH PLAIN dm1haWwAdm1haWwAdm1haWw=\n`
    - The base64 string is just `vmail\0vmail\0vmail` (\<userID\>\\0\<loginID\>\\0\<password\>)
  - Or, use `AUTH LOGIN dm1haWw=` as such:
```
HELO vmail
250 smtp-garden-dovecot
AUTH LOGIN dm1haWw=          # 'dm1haWw=' is 'vmail'
334 UGFzc3dvcmQ6
dm1haWw=
235 2.7.0 Logged in.
```

## LMTP Server
- Dovecot also listens on port 24 to provide LMTP services to local mailboxes.
- No authentication required, but Dovecot will only deliver to a local user with a valid ~/Maildir tree.
- Two local mailboxes have been created, to serve as adversarial local delivery targets
  - Usernames are `user1` and `user2`
  - Uses the Maildir++ directory format (~/Maildir/{cur, new, tmp})

