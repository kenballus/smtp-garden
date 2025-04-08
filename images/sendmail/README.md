## Sendmail
Sendmail MTA will send all email (except for local users) to `__RELAYHOST__` (see `garden_config.mc`, below).
- Messages addressed to a recognized local user (`user1` and `user2`) are stored in `spool/mqueue`.
  - `spool/` is accessible as a Docker volume.
  - This is a "backdoor" method for collecting locally-delivered emails, without the benefit of a Mail Delivery Agent (MDA).
  - Sendmail is not designed to deliver to individual user accounts; it is not an MDA.
- Messages addressed to an unrecognized local user are rejected.

## Key configuration items
- [site.config.m4](site.config.m4) configures build options, not server options
- [garden_config.mc](garden_config.mc) is concatenated to the default options in `/app/sendmail/cf/cf/generic-linux.mc` to generate `/app/sendmail/cf/cf/sendmail.mc`
- `sendmail.mc` is an m4 macro file that gets parsed to generate `/app/sendmail/cf/cf/sendmail.cf`, which is less human-friendly
- Open relay functionality depends on:
  - generating a `/etc/mail/access.db` map based on the string, 'Connect:ALL RELAY'
  - `garden_config.mc` options incorporated into `sendmail.cf`
- HELO name: `confHELO_NAME` target set in `/app/sendmail/cf/cf/sendmail.mc`, via `garden_config.mc`
- Target relay host: `SMART_HOST` target set in `/app/sendmail/cf/cf/sendmail.mc`, via `garden_config.mc`

## Other
Sendmail is started via a wrapper script.
- Manages filesystem permissions for `spool/` volume.
- Ensures the dynamically-assigned docker hostname is passed on to sendmail, preventing extended startup time.
- Passes TERM, INT signals for a graceful shutdown.

