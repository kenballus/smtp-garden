## Sendmail
Sendmail MTA will send all email (except for local users) to `__RELAYHOST__` (see `garden_config.mc`, below).
- Messages addressed to a recognized local user (`user1` and `user2`) are stored in `spool/mqueue`.
  - `spool/` is accessible as a Docker volume.
  - This is a "backdoor" method for collecting locally-delivered emails, without the benefit of a Mail Delivery Agent (MDA) such as procmail.
  - Sendmail is not designed to deliver to individual user accounts; it is not an MDA.
- Messages addressed to an unrecognized local user are rejected.

## Key configuration items
- [site.config.m4](site.config.m4) configures build options, not server options.
- [mailertable](mailertable) has simple SMTP routing for recognized garden hosts.
- [sendmail.mc](sendmail.mc) builds upon the default options in `/app/sendmail/cf/cf/generic-linux.mc`.
  - `confHELO_NAME` sets the HELO name.
  - `SMART_HOST' defines the fallback relay for any destination host not in `mailertable`.
  - Other settings generally enable SMTP Garden functionality and encourage DNS A record reliance.  Several of the settings are probably not strictly necessary.
  - `sendmail.mc` is an m4 macro file that gets parsed to generate `/app/sendmail/cf/cf/sendmail.cf`, which is less human-friendly
- Open relay functionality depends on:
  - `promiscuous_relay` feature in `sendmail.mc`
  - generating a `/etc/mail/access.db` map based on the string, 'Connect:ALL RELAY'

## Other
Sendmail is started via a wrapper script.
- Manages filesystem permissions for `spool/` volume.
- Ensures the dynamically-assigned docker hostname is passed on to sendmail, preventing extended startup time.
- Passes TERM, INT signals for a graceful shutdown.

## TODO
- [ ] Maildir tooling
- [ ] LMTP configuration
