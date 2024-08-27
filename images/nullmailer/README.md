## Key configuration items

Main config files are in /usr/local/etc/nullmailer
- `me` contains the HELO name.
- `remotes` contains smart host's name [along with any desired options].

## Basic [dys]function

nullmailer-smtpd, nullmailer-queue, and nullmailer-send work in concert.
- The current, simple Docker starting CMD is not optimized to pass on TERM, INT to nullmailer (#TODO).
- Use a payload that includes header lines.
  - nullmailer is finicky about the header, and crashes easily.
- nullmailer-smtpd is neither a true SMTP server nor a daemon on its own.
  - It works in this scenario by being invoked by netcat listening on port 25.
  - It acts as a wrapper for nullmailer-queue, which puts a new mail in the queue.
  - It requires the `MAIL FROM:<>` and `RCPT TO:<>` values to be fully qualified.
  - i.e., `<root@example.com>` works, but not `<root@example>` or `<root>`
- nullmailer-queue gets forked by nullmailer-smtpd after it receives "DATA" from client.
  - nullmailer-queue seems to work better/only when actual header lines are included
  - If nullmailer-queue crashes, nullmailer-smtpd will close the connection without explanation (other than possibly segmentation faulting)
  - nullmailer-queue in turn triggers nullmailer-send, which actually sends the mail to echo (i.e. the smart host).

