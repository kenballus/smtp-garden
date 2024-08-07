# SMTP Garden

## General

A containerized arrangement of various open-source SMTP servers for differential fuzzing.  Part of the [DIGIHEALS](https://github.com/narfindustries/digiheals-public) [ARPA-H](https://arpa-h.gov/) collaboration.

## Status (as of 7/30/2024)
- Configuration of SMTP servers: in progress
  - aiosmtpd, Apache James, Exim, OpenSMTPD, Postfix, and Sendmail are functional works-in-progress
  - other candidate SMTP servers/MTAs are listed in [issues](https://github.com/kenballus/smtp-garden/issues)
- Support containers: in progress / pre-implementation
  - echo server improved with async methods.  An output filter/beautifier would be nice.
  - An adversary container concept proposed, needs development
- Fuzzer: early development
  - A simple, payload delivery script is functional

## TODO
- See [issues](https://github.com/kenballus/smtp-garden/issues) tab for new candidate MTAs.
- [OpenSMTPD](images/opensmtpd) demonstrated stricter RFC 2822-enforcing behavior than the other relays.  Examine source further.
- [Apache James](images/james) (8/1/2024)
  - Further minimize changes to example config files
- [Exim](images/exim) (7/19/2024)
  - Explore pros/cons of other general alternate configurations
- [aiosmtpd](images/aiosmtpd) (7/26/2024)
  - Nice to have aiosmtpd HELO to echo with an explicit name instead of an IPv4 address, if there's a simple way
- All containers
  - Prune unneccessary build/environment components for efficiency (as needed)
- Ancillary
  - Consider scripting to alter configuration files, if this turns out to be a frequent thing

## Deployment (volatile)

### Build and tag individual containers

In `docker-compose.yml` and/or individual `Dockerfile`s, target relay hosts can be configured (default is `echo` for all).  This mechanism can be used to "daisy chain" servers, if desired.  See subfolder READMEs for synopses of each configuration and quick reference for key items.

```
.../images/smtp-garden-soil$ docker build -t smtp-garden-soil:latest .
.../images/james$ docker build -t smtp-garden-james:3.8.1 .
.../images/echo$ docker build -t smtp-garden-echo:latest .
.../images/postfix$ docker build -t smtp-garden-postfix:latest .
(etc)
```

### Deploy

```
docker compose up [echo] [postfix] [james] [exim] [...]
```
Add additional containers as they become functional


## Employment (early stage)
### Provisional localhost port assignment:
- 25 - echo
- 2501 - postfix
- 2502 - james
- 2503 - exim
- 2504 - aiosmtpd
- 2505 - sendmail
- 2506 - opensmtpd

(subject to change)

### Provisional payload delivery

Send file contents with sendmsg.py.  Alternatively, SMTP commands can be manually sent with telnet or netcat, but piping file contents is a brittle method (expect a 554 or other error).

```
./sendmsg.py message_file [server|"localhost"] [port|"25"]
```
Notes:
- If you only specify a server or a port, but not both, the script is smart enough to figure out what you meant, and will apply a default for the other value
  - `server` defaults to "localhost".
  - `port` defaults to 25. As for `server`, just give a number. i.e., `2501`, not `port=2501`
- See leading script comments/description for message_file formatting details.
- Note: Escape character parsing uses codecs.escape_decode(), an undocumented Python function, please report any unexpected results.

