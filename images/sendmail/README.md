## Attention!

Dockerfile updated and pushed (8/29/2024) for testing. This notice will be removed once it is verified.

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
- Starts sendmail via a wrapper script
  - Ensures the dynamically-assigned docker hostname is passed on to sendmail, preventing extended startup time
  - Passes TERM, INT signals for graceful shutdown
