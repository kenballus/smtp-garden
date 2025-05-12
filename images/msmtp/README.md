## Key configuration items

- Master configuration file is `/usr/local/etc/msmtprc` (self-explanatory)
- Created from Dockerfile

## TODO
- [ ] create a version of this image for msmtp to speak LMTP (i.e., to Dovecot)
- [ ] investigate EHLO behavior with echo server: When echo announces EHLO capacity, it breaks msmtp's DATA transmissions
