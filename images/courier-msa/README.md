## Key Configuration Items

Courier MTA is highly modular.  It has thorough documentation, but it is more reference than "how-to."
- This image runs the MSA server, not the SMTP server.  See [courier](../courier) and https://www.courier-mta.org/esmtpd.html
- Main config files are deployed to [/usr/lib/courier/etc](conf/)
- Main reference https://www.courier-mta.org/courier.html
- Provided in the repo:
  - `bofh`, `courierd` to minimize blacklisting impacts
  - `conf/esmtpacceptmailfor` - SMTP accepts emails for these domains. (running `makesmtpaccess` is optional if using this)
  - `esmtpd` and `esmtpd-msa` - main server settings
  - `emsptphelo` - self explanatory
  - `esmtproutes` - routing in the absence of MX records. Including updating `RELAYHOST`
  - `esmtptimeoutkeepalive` set to minimum, for improved compatibility with certain servers (i.e., msmtp)
  - `locals` - domains recognized as local
  - `me` - hostname
  - `aliases/` - aliases for `postmaster`
  - `smtpaccess/` - allowed inbound connections
- Updated in Dockerfile:
  - `authdaemonrc` - minor tweaks

## Building
- Could not get Github repo to build correctly, but tarball from Sourceforge works fine.
- Courier Authlib from debian repo did not have everything needed, so built from scratch (Also Sourceforge)

## Mailboxes
Two local mailboxes have been created, to serve as local delivery targets
- Usernames are user1 and user2
- Uses the Maildir directory format (~/Maildir/{cur, new, tmp})
- Container `/home` is volumized and mapped to `courier/home/` on the host
- Container start script manages filesystem permissions

