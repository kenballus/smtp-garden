## Key configuration items

Main config files are in /usr/local/etc/nullmailer
- `me` contains the HELO name.
- `remotes` contains smart host's name [along with any desired options].

To compile with LLVM, do one of these:
- compile with -Wno-c++11-narrowing
- compile with -std=c++03
- patch src/inject.cc line 153, changing `unsigned` type to `size_t` for the variable, `length`

## Basic [dys]function

nullmailer-smtpd, nullmailer-inject, nullmailer-queue, and nullmailer-send work in concert.
- nullmailer-smtpd is neither a true SMTP server nor a daemon on its own.
  - It works in this scenario by being invoked by netcat listening on port 25.
  - nullmailer-smtpd forks nullmailer-inject to put a new email in the queue, but error handling characteristics are poor.
  - It requires the `MAIL FROM:<>` and `RCPT TO:<>` values to be fully qualified.
  - i.e., `<root@example.com>` works, but not `<root@example>` or `<root>`
- nullmailer-queue gets forked by nullmailer-smtpd after it receives "DATA" from client.
  - nullmailer-queue in turn triggers nullmailer-send, which actually sends the mail to echo (i.e. the smart host).
- BUGS (9/10/2024):
  - unpatched code segfaults if a malformed payload causes nullmailer-queue to exit with a non-zero code
  - a simple patch (`sed` line in Dockerfile) fixes the out-of-bounds read condition, and has been reported.
  - a subsequent bug has been revealed in processing of the same malformed payloads, see issues tab
