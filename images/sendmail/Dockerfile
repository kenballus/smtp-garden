FROM smtp-garden-soil:latest

ARG APP_VERSION
ARG RELAYHOST

# Dev environment & pre-configuration
RUN apt -y update && apt -y upgrade \
  && apt -y --no-install-recommends install m4 wget libldap-dev libsasl2-dev libssl-dev libdb-dev \
  && wget "https://ftp.sendmail.org/sendmail.$APP_VERSION.tar.gz" -O sendmail.tgz \
  && tar xf sendmail.tgz \
  && mv "sendmail-$APP_VERSION" sendmail \
  && useradd -c "Sendmail Daemon" -d /dev/null -s /bin/false -u 26 smmsp \
  && chmod -v 1777 /var/mail \
  && install -v -m700 -d /var/spool/mqueue
COPY site.config.m4 /app/sendmail/devtools/Site/site.config.m4
COPY sendmail.mc /app/sendmail/cf/cf
RUN sed -i "s/__RELAYHOST__/${RELAYHOST}/" /app/sendmail/cf/cf/sendmail.mc
COPY mailertable /etc/mail/mailertable

# Build & Configure
RUN cd /app/sendmail/sendmail \
  && sh Build \
  && cd /app/sendmail/cf/cf \
  && sh Build sendmail.cf \
  && install -v -d -m755 /etc/mail \
  && sh Build install-cf \
  && cd ../.. \
  && sh Build install \
  && cp -v -R cf/* /etc/mail \
  && echo 'Connect:ALL RELAY' | makemap hash /etc/mail/access \
  && echo 'sendmail' > /etc/mail/local-host-names \
  && printf 'postmaster: nMAILER\root-DAEMON: root\n\n' > /etc/mail/aliases \
  && makemap hash /etc/mail/mailertable < /etc/mail/mailertable

# Start
COPY start-sendmail.sh /app/sendmail/start.sh
RUN chmod +x /app/sendmail/start.sh
WORKDIR /app/sendmail
CMD ["./start.sh"]
