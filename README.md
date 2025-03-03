# SMTP Garden

## General

A containerized arrangement of various open-source SMTP and SMTP-like servers for differential fuzzing.  Part of the [DIGIHEALS](https://github.com/narfindustries/digiheals-public) [ARPA-H](https://arpa-h.gov/) collaboration.

## Status (as of 2/27/2025)
- Configuration of SMTP servers is ongoing.
- Relay-only / MTA servers
  - aiosmtpd, msmtp, nullmailer, OpenSMTPD, Sendmail
  - \*Configuration underway for local delivery to file repository, stay tuned
- SMTP with relay and local delivery
  - Exim, Postfix, Apache James, OpenSMTPD
- Configuration of LMTP Servers: in progress
  - Dovecot
- Configuration of Submission Servers: in progress
  - Dovecot
- Other candidate SMTP servers/MTAs are listed in [issues](https://github.com/kenballus/smtp-garden/issues)
- Support containers:
  - echo server improved with async methods.  An output filter/beautifier and a batch sending ability would be nice.
  - DNS container for MX records ("dns-mx" running dnsmasq) on standby, but docker built-in DNS has been sufficient so far
    - Most servers seem to happily fall back on A records if MX record not available
    - This container will be removed if not needed
  - An adversary container concept proposed, needs development
- Fuzzing: early development
  - A simple, payload delivery script is functional (`sendmsg.py`)
  - Preliminary testing has identified a few server bugs so far
  - Future: docker volume-ized Maildir files for each container, for easy diff'ing and parsing.

## TODO (as of 3/2/2025)
- Update eligible images to volumize Maildir (or other file repository) tree
- Script to automatically update all image configurations when new servers are added or other routing rules change
- See [issues](https://github.com/kenballus/smtp-garden/issues) tab for new candidate servers.
- All containers
  - Continue Dockerfile migration to a standard style
- Add alias support to `sendmsg.py` to avoid needing to cross reference port numbers
- Batch mode for `sendmsg.py`

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

- Some servers require an alternate `APP_VERSION`, so check the YAML and don't assume it is always "master".
- See subfolder READMEs for each image for a configuration quick reference and brief overview.
- By modifying RELAYHOST for each image, servers can be arbitrarily "daisy chained," if desired.

### Deploy

```
docker compose up [-d] [echo] [postfix] [james] [exim] [...]
```
- The soil container never needs to be run

## Employment (volatile)
### Provisional localhost port assignment:
SMTP (mostly arbitrary order)
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
- See leading script comments/description for `message_file` formatting details.
- Note: Escape character parsing uses `codecs.escape_decode()`, an undocumented Python function, please report any unexpected results.
- The example payload file works fine for SMTP servers, but LMTP and Submission payloads require modification (i.e. LHLO, AUTH)
