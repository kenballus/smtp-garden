## aiosmtpd

A custom server using aiosmtpd python library.
- The default image acts as both a relay host for nonlocally addressed messages, and a message delivery agent that can deliver local emails to Maildir for local email.
- A simpler, earlier version of the server is provided for "relay only" functionality.

## Key configuration items
Key items are in `config.py`, which should be self-explanatory.

## Other
https://aiosmtpd.aio-libs.org/en/stable/index.html

## TODO
- [ ] LMTP mailer
- [ ] Routing and aliasing config
