## Key configuration items

Main config files are in /usr/local/etc/nullmailer
- `me` contains the HELO name.
- `remotes` contains smart host's name [along with any desired options].

To compile with LLVM, do one of these:
- compile with -Wno-c++11-narrowing
- compile with -std=c++03
- patch src/inject.cc line 153, changing `unsigned` type to `size_t` for the variable, `length`

## Basic function

#### nullmailer-smtpd, nullmailer-inject, nullmailer-queue, and nullmailer-send work in concert.
Nullmailer-smtpd is neither a true SMTP server nor a daemon on its own.  It is a "Simple relay-only mail transport agent" according to the maintainer.
  - nullmailer-smtpd works in this scenario by being invoked by netcat listening on port 25.
  - nullmailer-smtpd should require (but does not explicitly enforce) the `MAIL FROM:<>` and `RCPT TO:<>` values to be fully qualified.
  - i.e., `<root@example.com>` works, but `<root@example>` or `<root>` fail secondarily after the fork (due to SIGPIPE)
  - nullmailer-smtpd forks nullmailer-queue after receiving "DATA", but error handling characteristics are not exhaustive.
- nullmailer-queue receives message from nullmailer-smtpd and passes it to nullmailer-send.
- nullmailer-send sends the mail to echo (i.e. the smart host).

#### HISTORY (9/10/2024):
1. Unpatched code segfaults if a malformed payload causes nullmailer-queue to exit with a non-zero code
   - The underlying bug was reported in a different specific context, June 2024, on github repo and Debian bug list.
   - smtp-garden research explored and reported the generalized case
   - a simple patch (`sed` line in Dockerfile) fixes the out-of-bounds read condition.
   - Maintainer committed fix 79a8a45 in response.
2. The patched build reveals a latent bug in the src/smtpd.cc qwrite routine.
   - qwrite fails to confirm stream is valid before attempting write.
   - Program fails to capture SIGPIPE, exits unexpectely, code 141 (128+SIGPIPE).
   - Presence of a simple signal handler fixes bug (not implemented).
   - Reported to author 9/10/2024.

