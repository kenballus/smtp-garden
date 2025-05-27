# SMTP Garden

## General

A containerized arrangement of various open-source SMTP and SMTP-like servers for differential fuzzing and SMTP smuggling testing.  Part of the [DIGIHEALS](https://github.com/narfindustries/digiheals-public) [ARPA-H](https://arpa-h.gov/) collaboration.

The SMTP Garden contains 12 images derived from 10 independent SMTP server applications, plus 2 support images, and a foundational "soil" image.  It also includes directory trees used as Docker volumes, and various Python and bash utility scripts.

Work currently under development includes a scalable fuzzing framework and additional test subject servers.

## Status (as of 5/6/2025)
The garden has passed initial formal validation (i.e. comprehensive internal testing).  Minor modifications and improvements to existing servers are ongoing, but the garden is sufficient for fuzzing development.  New servers may be added any time.
- Images:
  - Relay-only / MTA servers
    - msmtp, nullmailer
  - SMTP with explicit routing, relay and local delivery
    - Maildir format-capable: aiosmtpd, Exim, Postfix, OpenSMTPD, Courier MTA, James\*
    - Local mail saved in spool/queue: Apache James\*, Sendmail (see TODO) 
    - \*James: The `james` image saves to a database in `inbox` only.  The `james-maildir` image has a custom mailet to save in Maildir format in addition to `inbox`.  Both images share a docker DNS name and a host listening port, so they cannot run simultaneously.
  - Configuration of LMTP Servers:
    - Dovecot
  - Configuration of Submission Servers:
    - Dovecot ("smarthost-only")
    - Courier MSA (Same as Courier MTA, but RFC 2476 compliant)
  - Other candidate SMTP servers/MTAs are listed in [issues](https://github.com/kenballus/smtp-garden/issues)
  - Support containers:
    - `echo` server improved with async methods sends all received data to stdout.
    - DNS container for MX records ("dns-mx" running dnsmasq) available on standby, but docker built-in DNS has been sufficient so far.
      - Most servers seem to happily fall back on A records if MX record not available.
      - This container will be removed if not needed.
- Validation:
  - Initial phase __Complete__ for all configurations as of 4/13/2025 (commit 69b24f5)
  - New server additional or major routing reconfigurations all require repeat validation on a rolling basis.
- Fuzzing: early development
  - A simple, payload delivery script is functional (`sendmsg.py`)
  - Various output collection tools now available, see below
  - Exploring various frameworks; TODO item
  - Pre-fuzzing testing identified a few server bugs
    - Independent discovery of Nullmailer type confusion bug and a latent SIGPIPE handling bug (low severity).

## TODO (as of 5/26/2025)
- __HIGH__ Explore fuzzing strategies and "off-the-shelf" options.
- __HIGH__ Configure eligible servers to relay to LMTP destinations, as able
  - Exim, Postfix done
  - Remaining: aiosmtpd, msmtp, opensmtpd, sendmail
- __HIGH__ Output gatherer-comparator: Need automation and a screening method for false-positives; Concept design stage
- MEDIUM Investigate why echo server breaks msmtp when echo announces "EHLO"
- MEDIUM Provide a Maildir delivery mechanism for Sendmail
  - Note: at this stage, this would be considered for convenience of output collection.  It has not yet been decided if SMTP-MDA smuggling is in scope or not.
- MEDIUM Scope discussion/determination: is SMTP-MDA smuggling in scope?  (i.e., James-{procmail,maildrop,fdm})
- LOW Optimize Dockerfiles for image size (i.e., James is huge)
- LOW Script to automatically update all image configurations when new servers are added or other routing rules change
- LOW Suggested: develop adversarial second-stage server, for responsive fuzzing of relaying servers.
  - Not clearly a smuggling vector; not yet confirmed in scope.
- Ongoing/as needed:
  - Add new servers, see [issues](https://github.com/kenballus/smtp-garden/issues), subject to re-validation.

## Validation Process (as of 4/13/2025)
Verification of expected __SMTP routing__ and __email delivery__ behavior is recommended prior to formal testing, for any new deployment or addition.
- Expected behavior:
  - Emails for *recognized users*, received by servers with local user inboxes, are delivered locally in Maildir format (*where currently capable. See James/sendmail exceptions*).
  - Emails for *unrecognized users*, recevied by servers with local user inboxes, are rejected (DSN to fallback server, in some cases)
  - Emails for any user, at a *recognized peer host*, are delivered directly to that host
    - Exception: submission / smarthost-only servers deliver everything to the designated target (usually, `echo`)
    - i.e., Dovecot submission server
  - Emails for any user, at *any unrecognized host*, are delivered to fallback server
  - fallback server is `echo` by default, but each container can be configured individually to use a unique fallback host (allows daisy-chaining)
  - Different servers handle rejection and generate backscatter differently.  This is fine/expected.
- Scripts for template-based generation of testing payloads are provided in [validation/](validation)

## Deployment (volatile)

### Host environment (as of 5/26/2025)

File tree __ownership__ and __permission management__ is necessary for __local user email delivery__ and __Maildir content retrieval from the host__.
- Update the values in your `.env` file to reflect your desired host user UID and GID.
- `images/<image>/home` trees get volumized by docker-compose, so ensure the appropriate `user{1,2}/Maildir/{new,cur,tmp}` subdirectories are intact.
- Ideal Maildir file permissions:
  - `<image>/home/` and subdirectories: mode 777
  - Maildir files: mode 666 (server-dependent)
  - `.gitignore` files: as desired (i.e., 600)
- TODO: Native permissions (checkbox = patched to 666, as needed):
  - [x] aiosmtpd: depends on umask (custom wrapper saves Maildir files as 666)
  - [x] dovecot: mode 666 (by default in current config)
  - [ ] exim: mode 750
  - [ ] james-maildir: mode 644
  - [ ] postfix: mode 600
  - [x] opensmtpd: mode 600
  - [x] courier[-msa]: mode 600
  - [ ] sendmail: ? (still needs a mail dropper)
- Server start scripts within each Docker image should take care of file system ownership automatically.
- Those same start scripts trap SIGINT and SIGTERM, and will reassign ownership to the UID and GID set in `.env` upon container shutdown
  - In some environments CTRL-C (instead of `docker-compose {down | stop}`) may not get trapped
- The fix, if file ownership has been mangled, and you can't access Maildirs from the host:
  - Re-launch the container (via compose) and ensure the volume is attached
  - Within the container, run `chown -R <UID>:<GID> /home`
  - This will temporarily break the server's local mail delivery, but you can now access `images/<image>/home` contents at will, as the host user
  - Start script will reset permissions correctly next time the container is started.
- Exceptions:
  - Apache James: use james-maildir image for Maildir capability, see the [James README](images/james) and the [james-maildir README](images/james-maildir) for details.
  - Sendmail: Since it does not have MDA capacity, locally addressed messages can be gathered from `/var/spool/mqueue`, see [README](images/sendmail) (and TODO).

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

Note: To run multiple instances of the garden on the same Docker host simultaneously, use unique host port mappings in each `docker-compose.yml` config.

### Default localhost port assignment:
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

## Output Collection (5/6/2025)
Payloads are ultimately delivered to stdout or a volume.
- `echo` outputs all sent/received traffic to stdout
- A host's `image/<server>/home` folders are bind mounted to each container's `/home` for Docker host-based access.
  - i.e. `images/exim/home/user1/Maildir` binds Exim container's `/home/user1/Maildir`
  - File system permission management:
    - Server start scripts in each Docker image should take care of file system and volume permissions (see "Deployment:Host Environment" above)
    - Without root on host, you may not be able to directly access volume contents while a container is running (without `exec`ing into the container)
- Shell scripts
  - `shownew.sh` to list (and optionally print contents of) files in `Maildir/new` directories
  - `diffnew.sh` finds files in `Maildir/new` directories and diffs them
  - `markread.sh` to move emails between `Maildir/new/` and `Maildir/cur/` directories
  - `purge.sh` will delete all volume files not called `.gitignore`.

## Issues/Troubleshooting
Please submit a new github issue or contact the maintainers directly.

