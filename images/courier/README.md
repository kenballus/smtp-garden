## Courier-MTA

Courier MTA is highly modular.  It has thorough documentation, but it is more reference than "how-to."
- Main config files are deployed to [/usr/lib/courier/etc](courierconf/)
- Main reference https://www.courier-mta.org/courier.html
- Provided in the repo:
  - courierconf/esmtpacceptmailfor - SMTP accepts emails for these domains. (running `makesmtpaccess` is optional if using this)
  - esmtpd and esmtpd-msa - main server settings
  - emsptphelo - self explanatory
  - esmtproutes - routing in the absence of MX records. Including updating `RELAYHOST`
  - locals - domains recognized as local
  - me - hostname
  - aliases/ - aliases for `postmaster`
  - smtpaccess/ - allowed inbound connections
- Updated in Dockerfile:
  - authdaemonrc - minor tweaks

Building:
- Could not get Github repo to build correctly, but tarball from Sourceforge works fine.
- Courier Authlib from debian repo did not have everything needed, so built from scratch (Also Sourceforge)

Other:
- New feature! When the container is shut down properly, the start script will attempt to reassign ownership of contents of /home for host user access (instead of leaving Docker's leftover UID/GID settings)
