# SMTP Garden

## General

A containerized arrangement of various open-source SMTP servers for differential fuzzing.  Part of the [DIGIHEALS](https://github.com/narfindustries/digiheals-public) [ARPA-H](https://arpa-h.gov/) collaboration.

## Status (as of 7/20/2024)
- Configuration of SMTP servers: in progress
  - JAMES, Postfix, and exim are functional works-in-progress
  - Several other SMTP servers are in a pre-configuration state
- Support containers: in progress / pre-implementation
  - echo server improved with async methods.  An output filter/beautifier would be nice.
  - An adversary container concept proposed, needs development
- Fuzzer: not begun
  - Simple payload delivery script works

## TODO
- postfix
  - make postfix HELO as something informative ("postfix") (7/20/2024)
- exim
  - make exim HELO as something informative ("exim") (7/20/2024)
  - explore pros/cons of other general alternate configurations (7/19/2024)
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
### Provisional localhost port assignment:
- 25 - echo
- 2501 - postfix
- 2502 - james
- 2503 - exim

### Provisional payload delivery

Send file contents with sendmsg.py.  Alternatively, SMTP commands can be manually sent with telnet or netcat.  Piping file contents is brittle.

```
./sendmsg.py message_file localhost [port=25]
```
Notes: sendmsg reads and sends one line at a time.  Lines are delimited by mandatory newline bytes, but these newline bytes are stripped prior to sending.  Failure to send lines individually may lead to a 554 error.  Escaped characters within the line of text are interpreted according to Python rules and transmitted.  So, literal tokens can be sent as-is, by escaping the backslash ('\') character itself.  And, explicit bytes can be sent in hex or octal, such as '\x41' or '\101'.  Normally (if not part of your fuzzing protocol), each line should end with a '\r\n' token to signifiy to the SMTP server the end of the SMTP command, otherwise the server may time out on you.  See example files.
