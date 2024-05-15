FROM smtp-garden-soil:latest

RUN apt -y update && apt -y upgrade && apt -y install pkg-config libevent-dev libssl-dev autoconf automake bison libtool

RUN git clone https://github.com/OpenSMTPD/OpenSMTPD.git && cd OpenSMTPD && ./bootstrap && ./configure && make && make install

RUN ln -s /usr/sbin/smtpctl sendmail && ln -s /usr/sbin/smtpctl send-mail && ln -s /usr/sbin/smtpctl mailq && ln -s /usr/sbin/smtpctl makemap && ln -s /usr/sbin/smtpctl newaliases
RUN mkdir /var/empty && useradd -c "SMTP Daemon" -d /var/empty -s /sbin/nologin _smtpd && useradd -c "SMTPD Queue" -d /var/empty -s /sbin/nologin _smtpq

RUN mkdir /etc/mail && touch /etc/mail/aliases

CMD ["smtpd", "-dv"]
