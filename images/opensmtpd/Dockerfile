FROM smtp-garden-soil:latest

# Dev environment
ARG APP_VERSION
RUN apt -y update && apt -y upgrade \
  && apt -y --no-install-recommends install pkg-config libevent-dev libssl-dev autoconf automake bison libtool \
  && git clone --recurse-submodules https://github.com/OpenSMTPD/OpenSMTPD.git

# Override Maildir file tree permissions with patch, to facilitate data recovery, before building
COPY patch.diff /app/OpenSMTPD/usr.sbin/smtpd/patch.diff
RUN cd /app/OpenSMTPD \
  && git checkout "$APP_VERSION" \
  && cd /app/OpenSMTPD/usr.sbin/smtpd \
  && patch < patch.diff \
  && cd /app/OpenSMTPD \
  && ./bootstrap \
  && ./configure \
  && make && make install

# Configure
COPY smtpd.conf /usr/local/etc/smtpd.conf
COPY peer_domains /usr/local/etc/peer_domains
ARG RELAYHOST
RUN ln -s /usr/sbin/smtpctl sendmail \
  && ln -s /usr/sbin/smtpctl send-mail \
  && ln -s /usr/sbin/smtpctl mailq \
  && ln -s /usr/sbin/smtpctl makemap \
  && ln -s /usr/sbin/smtpctl newaliases \
  && mkdir /var/empty \
  && useradd -c "SMTP Daemon" -d /var/empty -s /sbin/nologin _smtpd \
  && useradd -c "SMTPD Queue" -d /var/empty -s /sbin/nologin _smtpq \
  && sed -i "s/__RELAYHOST__/${RELAYHOST}/" /usr/local/etc/smtpd.conf \
  && find /home -type d -print0 | xargs -0 chmod 777 \
  && find /home -type f -print0 | xargs -0 chmod 666
# TODO: move the find commands to soil after testing other servers for it

# Go
#CMD ["smtpd", "-d", "-T", "all"]
COPY start-opensmtpd.sh /app
CMD ["/app/start-opensmtpd.sh"]

