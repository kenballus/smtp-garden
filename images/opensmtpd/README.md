## Key configuration items

- Target relay host: follows `relay host` in smtpd.conf, in quotes.
- HELO name: follows `helo` in smtpd.conf, in quotes.
- Default location for current "master" version: [/usr/local/etc/smtpd.conf](smtpd.conf), which is the only required file.
  - Take note: many online references describe the default location as `/etc`, `/etc/mail`, or other locations, perhaps based on different versions.
  - If your config file has an error in it, running `smtpd -n` will report the error along side the file location and line number.  If there are no errors, it assumes you know which file it is parsing. 
  - Alternate locations can be used with the `-f /path/to/file` command line argument.
- Local users are recognized by the full hostname (i.e. @opensmtpd.smtp.garden)
- SMTP Garden peers are recognized by the file `peer_relays`
- Everything else goes to echo

## Mailboxes
- Two local mailboxes have been created, to serve as local delivery targets
  - Usernames are user1 and user2
  - Uses the Maildir directory format (~/Maildir/{cur, new, tmp})
  - Container `/home` is volumized and mapped to `opensmtpd/home/` on the host
  - Container start script manages filesystem permissions

## Other
- Email RCPT TO fields without a domain will be rejected.
- i.e. `user1@localhost` is delivered to the system user, but just addressing to `user1` is rejected.
- This relay is pickier about RFC 2822, and more likely to reject test messages.  It seems to:
  - Require at least one colon character, ie ':' somewhere in the DATA body.
    - See rfc5322.c and smtp_session.c in OpenSMTPD/usr.sbin/smtpd
    - Appears to be checking that at least one header line exists, in this way
  - Reject any DATA message that contains an \n byte before the terminal `\r\n.\r\n`.

## TODO
- [ ] LMTP mailer
