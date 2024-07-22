# SMTP Garden

## General

A containerized arrangement of various open-source SMTP servers for differential fuzzing.  Part of the [DIGIHEALS](https://github.com/narfindustries/digiheals-public) [ARPA-H](https://arpa-h.gov/) collaboration.

## Status (as of 7/22/2024)
- Configuration of SMTP servers: in progress
  - Apache James, Postfix, and Exim are functional works-in-progress
  - Several other SMTP servers are in a pre-configuration state
- Support containers: in progress / pre-implementation
  - echo server improved with async methods.  An output filter/beautifier would be nice.
  - An adversary container concept proposed, needs development
- Fuzzer: not begun
  - A simple, payload delivery script is functional

## TODO
- Finish general configuration:
  - [aiosmtp](images/aiosmtp)
  - [opensmtpd](images/opensmtpd)
  - [sendmail](images/sendmail)
- [Apache James](images/james) (7/12/2024)
  - Migrate source accession from Apache.org zip file to github, with argument-based branch selection
  - Prune unneccessary components from build and configuration
- [Exim](images/exim) (7/19/2024)
  - explore pros/cons of other general alternate configurations
- All containers
  - Prune unneccessary build/environment components for efficiency (as needed)
- Ancillary
  - Consider scripting to alter configuration files, if this turns out to be a frequent thing
- Also see [issues](https://github.com/kenballus/smtp-garden/issues) tab.


## Deployment (volatile)
### Build and tag individual containers
In `docker-compose.yml` and/or individual `Dockerfile`s, target relay hosts can be configured (default is `echo` for all).  This mechanism can be used to "daisy chain" servers, if desired.  See subfolder READMEs for synopses of each configuration and quick reference for key items.

```
.../images/smtp-garden-soil$ docker build -t smtp-garden-soil:latest .
.../images/echo$ docker build -t smtp-garden-echo:latest .
.../images/postfix$ docker build -t smtp-garden-postfix:latest .
.../images/james$ docker build -t smtp-garden-james:3.8.1 .
.../images/exim$ docker build -t smtp-garden-exim:latest .
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

### Provisional payload delivery

Send file contents with sendmsg.py.  Alternatively, SMTP commands can be manually sent with telnet or netcat, but piping file contents is a brittle method (expect a 554 or other error).

```
./sendmsg.py message_file server [port|25]
```
Notes:
- `server` is probably going to be "localhost", unless you set up your own custom routing
- `port` defaults to 25. Just give a number. i.e., `2501`, not `port=2501`
- sendmsg reads and sends one line at a time from `message_file`
- Lines are delimited by mandatory newline bytes (which also help human-readability), but these newline bytes are stripped prior to sending.
- Normally (if not part of your fuzzing protocol), each line should end with a '\r\n' token to signifiy to the SMTP server the end of the SMTP command, otherwise the server may time out on you.  See example .txt files.
- Escaped characters within the line of text are interpreted according to Python rules and transmitted.  So, literal tokens can be sent as-is, with an escaped backslash ('\\\\').  And, explicit bytes can be sent in hex or octal, such as '\x41' or '\101'.
- Escape parsing uses codecs.escape_decode(), an undocumented Python function, please report any unexpected results.
