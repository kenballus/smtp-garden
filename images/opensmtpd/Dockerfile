FROM smtp-garden-soil:latest

ARG APP_VERSION=master
ARG RELAYHOST=echo

# Prepare, fetch & build
RUN apt -y update && apt -y upgrade && apt -y install pkg-config libevent-dev libssl-dev autoconf automake bison libtool
RUN git clone https://github.com/OpenSMTPD/OpenSMTPD.git && \
    cd OpenSMTPD && \
    git checkout $APP_VERSION && \
    ./bootstrap && \
    ./configure && \
    make && make install

# Configure
COPY smtpd.conf /usr/local/etc/smtpd.conf
RUN ln -s /usr/sbin/smtpctl sendmail && \
    ln -s /usr/sbin/smtpctl send-mail && \
    ln -s /usr/sbin/smtpctl mailq && \
    ln -s /usr/sbin/smtpctl makemap && \
    ln -s /usr/sbin/smtpctl newaliases && \
    mkdir /var/empty && \
    useradd -c "SMTP Daemon" -d /var/empty -s /sbin/nologin _smtpd && \
    useradd -c "SMTPD Queue" -d /var/empty -s /sbin/nologin _smtpq && \
    sed -i "s/__RELAYHOST__/${RELAYHOST}/" /usr/local/etc/smtpd.conf

# Go
CMD ["smtpd", "-d"]


