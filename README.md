# SMTP Garden

## General

A containerized arrangement of various open-source SMTP and SMTP-like servers for differential fuzzing.  Part of the [DIGIHEALS](https://github.com/narfindustries/digiheals-public) [ARPA-H](https://arpa-h.gov/) collaboration.

## Status (as of 9/16/2024)
- Configuration of SMTP servers: in progress
  - aiosmtpd, Apache James, Exim, Msmtp, nullmailer, OpenSMTPD, Postfix, and Sendmail are functional with primary configurations
- Configuration of LMTP Servers: in progress
  - Dovecot
- Configuration of Submission Servers: in progress
  - Dovecot
- Other candidate SMTP servers/MTAs are listed in [issues](https://github.com/kenballus/smtp-garden/issues)
- Support containers: in progress / pre-implementation
  - echo server improved with async methods.  An output filter/beautifier would be nice.
  - An adversary container concept proposed, needs development
- Fuzzing: early development
  - A simple, payload delivery script is functional
  - Preliminary testing has identified a few bugs so far

## TODO (as of 9/16/2024)
- See [issues](https://github.com/kenballus/smtp-garden/issues) tab for new candidate servers (especially ~~Dovecot,~~ Twisted).
- All containers
  - Continue Dockerfile migration to a standard style

## Deployment (volatile)

### Build and tag containers

The target images can conveniently be build with docker compose, starting with [smtp-garden-soil](images/smtp-garden-soil):
```
smtp-garden$ docker compose build soil
smtp-garden$ docker compose build [echo] [msmtp] [...]
```
Or, built directly, individually:
```
images/smtp-garden-soil$ docker build -t smtp-garden-soil:latest .
images/smtp-garden-exim$ docker build -t smtp-garden-exim:latest --build-arg=APP_VERSION=master --build-arg=RELAYHOST=echo .
# etc for additional images.  The build-args are required.
```

- Some servers require an alternate APP_VERSION, so check the YAML and don't assume it is always "master".
- See subfolder READMEs for each image for a configuration quick reference and brief overview.
- By modifying RELAYHOST, servers can be "daisy chained," if desired.

### Deploy

```
docker compose up [echo] [postfix] [james] [exim] [...]
```
- The soil container never needs to be run

## Employment (early stage)
### Provisional localhost port assignment:
SMTP
- 25 - echo
- 2501 - postfix
- 2502 - james
- 2503 - exim
- 2504 - aiosmtpd
- 2505 - sendmail
- 2506 - opensmtpd
- 2507 - nullmailer
- 2508 - msmtp

LMTP
- 2401 - dovecot

Submission Servers
- 2601 - dovecot (see [special AUTH notes](images/dovecot))

(subject to change)

### Provisional payload delivery

#### Option 1. `netcat` (or similar tool): 
- Piping file contents can be brittle (expect a 554 or other error unless server explicitly allows pipelining).
- Depending on your build/system, you can probably send escape codes manually
- i.e., by pressing `[ctrl-V]`, `[ctrl-M]`, `[ctrl-M]`, `.`, `[ctrl-V]`, `[ctrl-M]`, `[ctrl-M]`, you can send \<CR>\<LF>.\<CR>\<LF>

#### Option 2. Sending file contents with sendmsg.py:

```
./sendmsg.py message_file [server|"localhost"] [port|"25"]
```
- If you only specify a server or a port, but not both, the script is smart enough to figure out what you meant, and will apply a default for the other value
  - `server` defaults to "localhost".
  - `port` defaults to 25. As for `server`, just give a number. i.e., `2501`, not `port=2501`
- See leading script comments/description for message_file formatting details.
- Note: Escape character parsing uses codecs.escape_decode(), an undocumented Python function, please report any unexpected results.
- The example payload file works fine for SMTP servers, but LMTP and Submission payloads require modification (i.e. LHLO, AUTH)
