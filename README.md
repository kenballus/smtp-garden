# SMTP Garden

## General

A containerized arrangement of various open-source SMTP servers for differential fuzzing.  Part of the [DIGIHEALS](https://github.com/narfindustries/digiheals-public) [ARPA-H](https://arpa-h.gov/) collaboration.

## Status (as of 7/19/2024)

- Configuration of SMTP servers: in progress
  - JAMES, Postfix, and exim are functional works-in-progress
  - Several other SMTP servers are in a pre-configuration state
- Support containers: in progress / pre-implementation
  - Basic echo container functional.  An output filter/beautifier would be nice.
  - An adversary container concept proposed, needs development
- Fuzzer: not begun
  - Simple payload delivery script works

## TODO (7/19/2024)

- exim (7/19/2024)
  - explore pros/cons of alternate configurations
- JAMES (7/12/2024)
  - Migrate source accession from Apache.org zip file to github, with argument-based branch selection
  - Prune unneccessary components from build and configuration
- General configuration:
  - aiosmtp
  - opensmtpd
  - sendmail
- All containers
  - Prune unneccessary build/environment components for space saving (as needed)
- Ancillary
  - If it is anticipated that frequent changes will be made to various containers' designated relay hosts, consider a scripted updating method for altering configuration files.
  - Also see [issues](https://github.com/kenballus/smtp-garden/issues) tab.


## Deployment (volatile)
### Build and tag individual containers
In `docker-compose.yml` and/or individual `Dockerfile`s, target relay hosts can be configured (default is `echo` for all).  This mechanism can be used to "daisy chain" servers, if desired.  After building a container, see individual READMEs for location of key configuration items.

```
.../images/smtp-garden-soil$ docker build -t smtp-garden-soil:latest .
.../images/echo$ docker build -t smtp-garden-echo:latest .
.../images/postfix$ docker build -t smtp-garden-postfix:latest .
.../images/james$ docker build -t smtp-garden-james:3.8.1 .
.../images/exim$ docker build -t smtp-garden-exim:latest .
```
### Deploy

```
docker compose up [echo] [postfix] [james] [exim]
```
Add additional containers as they become functional


## Employment (early stage)
Provisional localhost port assignment:
- 25 - echo
- 2501 - postfix
- 2502 - james
- 2503 - exim

```
./sendmsg.py [message_file] localhost [port]
```
Note: actual line breaks and carriage returns (i.e., 0x0D and 0x0A bytes) in the message_file are ignored, but they can be retained for human readability.  Literal '\r' and '\n' tokens are encoded prior to transmission, to allow firm control of these bytes.  No methods are in place for escaping these characters, currently.


