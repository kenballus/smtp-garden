FROM smtp-garden-soil:latest

ARG APP_VERSION="8.18.1"
ARG RELAYHOST=echo

# Fetch source, unpack, pre-build
WORKDIR /app
RUN apt -y update && apt -y upgrade && \
    apt -y install m4 wget libldap-dev libsasl2-dev libssl-dev libdb-dev
RUN wget "https://ftp.sendmail.org/sendmail.$APP_VERSION.tar.gz" -O sendmail.tgz
RUN tar xf sendmail.tgz && \
    mv "sendmail-$APP_VERSION" sendmail && \
    useradd -c "Sendmail Daemon" -d /dev/null -s /bin/false -u 26 smmsp && \
    chmod -v 1777 /var/mail && \
    install -v -m700 -d /var/spool/mqueue
COPY site.config.m4 /app/sendmail/devtools/Site/site.config.m4
COPY garden_config.mc /app/sendmail/cf/cf/garden_config.mc
RUN sed -i "s/__RELAYHOST__/${RELAYHOST}/" /app/sendmail/cf/cf/garden_config.mc

# Build from source, build configuration files
WORKDIR /app/sendmail/sendmail
RUN sh Build 
WORKDIR /app/sendmail/cf/cf
RUN cat generic-linux.mc garden_config.mc >> sendmail.mc && \
    sh Build sendmail.cf && \
    install -v -d -m755 /etc/mail && \
    sh Build install-cf && \
    cd ../.. && \
    sh Build install && \
    cp -v -R cf/* /etc/mail && \
    echo 'Connect:ALL RELAY' | makemap hash /etc/mail/access && \
    echo 'sendmail' > /etc/mail/local-host-names && \
    printf 'postmaster: root\nMAILER-DAEMON: root\n\n' > /etc/mail/aliases

# Start
WORKDIR /app/sendmail
COPY start.sh /app/sendmail/start.sh
RUN chmod +x start.sh
CMD ["./start.sh"]
