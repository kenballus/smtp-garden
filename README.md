# SMTP Garden

## General

A containerized arrangement of various open-source SMTP and SMTP-like servers for differential fuzzing.  Part of the [DIGIHEALS](https://github.com/narfindustries/digiheals-public) [ARPA-H](https://arpa-h.gov/) collaboration.

## Status (as of 3/5/2025)
The SMTP garden is ready for fuzzing development.
- Images:
  - Relay-only / MTA servers
    - aiosmtpd, msmtp, nullmailer, Sendmail
  - SMTP with relay and local delivery
    - Exim, Postfix, Apache James, OpenSMTPD
  - Configuration of LMTP Servers:
    - Dovecot
  - Configuration of Submission Servers (i.e. "smarthost-only"):
    - Dovecot
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

## TODO (as of 3/5/2025)
- __HIGH__ Payload generator: Need a generator; Concept design stage.
- __HIGH__ Output comparator: Need automation and a screening method for false-positives; Concept design stage
- MEDIUM Streamline permissions for host accessing the files created in bind-mounted directories
- MEDIUM Batch mode for `sendmsg.py`
- LOW Script to automatically update all image configurations when new servers are added or other routing rules change
- LOW See [issues](https://github.com/kenballus/smtp-garden/issues) tab for new candidate servers.
- LOW Optimize Dockerfiles for image size (i.e., James is huge)
- LOW Add alias support to `sendmsg.py` to avoid needing to cross reference port numbers

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

Ensure the appropriate `images/<image>/home/` trees have `user1/Maildir` and `user2/Maildir` and necessary subdirectories intact, with all folder permissions set to 666.

### Build and tag containers

Servers build from source, and which be time-consuming.  Expect up to 8-10 minutes for James and Dovecot on a reasonably fast machine.  The target images can conveniently be built with docker compose, starting with [smtp-garden-soil](images/smtp-garden-soil):
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

## Output Collection
- `echo` outputs all sent/received traffic to stdout
- Host's `image/<image_name>/home` folders are bind mounted to each container's `/home` for Docker host-based access.
  - i.e. `images/exim/home/user1/Maildir` binds Exim container's `/home/user1/Maildir`
  - Make sure the host directory tree is permissively (666) configured, or servers will probably fail to write to file.
  - The container user's UID:GID is assigned to all files created by the container, which likely are assigned permission 600.  This stands in the way of the host user access.
  - Workaround: before extracting the outputs from the container, change ownership from within the container
    - Remember, its UID and GID that matter, not username or groupname
    - `docker exec -it <container> chown -R $(id -u):$(id -g) /home/*`

## Issues/Troubleshooting
Please submit a new github issue or contact the maintainers directly.
