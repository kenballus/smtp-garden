FROM smtp-garden-soil:latest

# Dev environment
ARG APP_VERSION
RUN apt -y update && apt -y upgrade \
  && apt -y --no-install-recommends install pkg-config libevent-dev libssl-dev autoconf automake bison libtool \
  && git clone --recurse-submodules https://github.com/OpenSMTPD/OpenSMTPD.git \
# Build
  && cd OpenSMTPD \
  && git checkout "$APP_VERSION" \
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
  && useradd user1 && useradd user2 \
  && mkdir -p /home/user1/Maildir/cur && mkdir /home/user1/Maildir/new && mkdir /home/user1/Maildir/tmp && chown -R user1:user1 /home/user1 \
  && mkdir -p /home/user2/Maildir/cur && mkdir /home/user2/Maildir/new && mkdir /home/user2/Maildir/tmp && chown -R user2:user2 /home/user2

# Go
#CMD ["smtpd", "-d", "-T", "all"]
COPY start-opensmtpd.sh /app
CMD ["/app/start-opensmtpd.sh"]

