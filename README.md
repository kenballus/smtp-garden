# SMTP Garden

## General

A containerized arrangement of various open-source SMTP and SMTP-like servers for differential fuzzing.  Part of the [DIGIHEALS](https://github.com/narfindustries/digiheals-public) [ARPA-H](https://arpa-h.gov/) collaboration.

## Status (as of 3/31/2025)
The SMTP garden is undergoing formal validation and final routing troubleshooting.  It is ready for fuzzing development.  New servers may be added any time.
- Images:
  - Relay-only / MTA servers
    - aiosmtpd, msmtp, nullmailer, Sendmail
  - SMTP with relay and local delivery
    - Exim, Postfix, Apache James, OpenSMTPD, Courier MTA
- Configuration of LMTP Servers:
    - Dovecot
  - Configuration of Submission Servers:
    - Dovecot ("smarthost-only")
    - Courier MSA (Same as Courier MTA, but RFC 2476 compliant)
  - Other candidate SMTP servers/MTAs are listed in [issues](https://github.com/kenballus/smtp-garden/issues)
  - Support containers:
    - `echo` server improved with async methods.  An output filter/beautifier and a batch sending ability would be nice.
    - DNS container for MX records ("dns-mx" running dnsmasq) on standby, but docker built-in DNS has been sufficient so far
      - Most servers seem to happily fall back on A records if MX record not available
      - This container will be removed if not needed
- Fuzzing: early development
  - A simple, payload delivery script is functional (`sendmsg.py`)
  - see TODO below / [issues](https://github.com/kenballus/smtp-garden/issues)
  - Pre-fuzzing testing identified a few server bugs

## TODO (as of 3/20/2025)
- __HIGH__ Payload generator: Need a generator; Concept design stage.
- __HIGH__ Output comparator: Need automation and a screening method for false-positives; Concept design stage
- __HIGH__ Establish scope of rejection by servers receiving payloads from Courier, Exim, etc
- LOW Script to automatically update all image configurations when new servers are added or other routing rules change
- LOW See [issues](https://github.com/kenballus/smtp-garden/issues) tab for new candidate servers.
- LOW Optimize Dockerfiles for image size (i.e., James is huge)

## Validation
- Expected behavior:
  - Emails for *recognized users*, received by servers with local user inboxes, are delivered locally in Maildir format
  - Emails for *unrecognized users*, recevied by servers with local user inboxes, are rejected (DSN to fallback server)
  - Emails for any user, at a *recognized peer host*, are delivered directly to that host
    - Exception: submission / smarthost-only servers deliver everything to the designated target (usually, `echo`)
    - i.e., Dovecot submission server
  - Emails for any user, at *any unrecognized host*, are delivered to fallback server
  - fallback server is `echo` by default, but each container can be configured individually to use a unique fallback host (allows daisy-chaining)
- A non-exhaustive collection of test payloads is provided in [validation/](validation)

## Deployment (volatile)

### Host environment

File tree permission management is necessary for __local user email delivery__ and __Maildir content retrieval from the host__.
- Update the values in your `.env` file to reflect your desired host user UID and GID.
- `images/<image>/home` trees get volumized by docker-compose, so ensure the appropriate `user{1|2}/Maildir/{new|cur|tmp}` subdirectories are intact.
- Server start scripts within each Docker image should take care of file system permissions automatically.
- Those same start scripts trap SIGINT and SIGTERM, and will reassign ownership to the UID and GID set in `.env` upon container shutdown
  - In some environments CTRL-C (instead of `docker-compose {down | stop}`) may not get trapped
- The fix, if file ownership has been mangled, and you can't access Maildirs from the host:
  - Re-launch the container and ensure the volume is attached
  - Within the container, run `chown -R <UID>:<GID> /home`
  - This will temporarily break the server's local mail delivery, but you can now access `images/<image>/home` contents at will, as the host user
  - Start script will reset permissions correctly next time the container is started.

### Build and tag containers

Servers build from source, and which be time-consuming.  Expect up to 8-10+ minutes for Courier [MSA], James and Dovecot on a reasonably fast machine.  The target images can conveniently be built with docker compose, starting with [smtp-garden-soil](images/smtp-garden-soil):
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

- Some servers require an alternate `APP_VERSION`, so check the YAML and the repo, and don't assume it is always "master".
- See subfolder READMEs for each image for a configuration quick reference and brief overview.
- By modifying RELAYHOST for each image, servers can be arbitrarily "daisy chained," if desired.
- If an image won't build or a container won't start, check for new commits and revert to an earlier commit, if necessary.  Everything builds well as of this README.

### Deploy

```
docker compose up [--build] [-d] [echo] [postfix] [james] [exim] [...]
```
- The soil container never needs to be run, but `docker compose up` by itself works fine.

## Employment (volatile)
### Provisional localhost port assignment:
SMTP (mostly arbitrary order)
- 25 - echo
- 2501 - aiosmtpd 
- 2502 - courier
- 2503 - exim
- 2504 - james
- 2505 - msmtp
- 2506 - (reserved)
- 2507 - nullmailer
- 2508 - opensmtpd
- 2509 - postfix
- 2510 - sendmail

LMTP
- 2401 - dovecot

Submission Servers
- 2601 - courier-msa
- 2602 - dovecot (see [special AUTH notes](images/dovecot))
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
- __Pro Tip:__ set appropriately-named environment variables to respective ports, so you don't have to remember container-to-port mapping:
```
aiosmtpd=2501
./sendmsg.py message_file $aiosmtpd
```

## Output Collection
- `echo` outputs all sent/received traffic to stdout
- Host's `image/<image_name>/home` folders are bind mounted to each container's `/home` for Docker host-based access.
  - i.e. `images/exim/home/user1/Maildir` binds Exim container's `/home/user1/Maildir`
  - Server start scripts in each Docker image should take care of file system and volume permissions (see "Deployment:Host Environment" above)

## Issues/Troubleshooting
Please submit a new github issue or contact the maintainers directly.
