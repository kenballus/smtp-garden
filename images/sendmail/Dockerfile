FROM smtp-garden-soil:latest

RUN apt -y update && apt -y upgrade && apt -y install m4 wget libldap-dev libsasl2-dev libssl-dev

ARG APP_VERSION
RUN wget "https://ftp.sendmail.org/sendmail.$APP_VERSION.tar.gz" -O sendmail.tgz && tar xf sendmail.tgz && mv "sendmail-$APP_VERSION" sendmail

RUN useradd -c "Sendmail Daemon" -d /dev/null -s /bin/false -u 26 smmsp && chmod -v 1777 /var/mail && install -v -m700 -d /var/spool/mqueue

COPY site.config.m4 /app/sendmail/devtools/Site/site.config.m4

RUN cd sendmail/sendmail && sh Build && cd ../cf/cf && cp generic-linux.mc sendmail.mc && printf "FEATURE(\`nullclient',\`echo') dnl\n" >> sendmail.mc && sh Build sendmail.cf && install -v -d -m755 /etc/mail && sh Build install-cf && cd ../.. && sh Build install && cp -v -R cf/* /etc/mail

RUN echo 'sendmail' > /etc/mail/local-host-names && printf 'postmaster: root\nMAILER-DAEMON: root\n\n' > /etc/mail/aliases

CMD sendmail -bd && echo 'I have finally come online' && sleep infinity
