FROM smtp-garden-soil:malcolm

ARG MYDESTINATION=postfix
ARG RELAYHOST=echo

RUN apt -y update && apt -y upgrade && apt -y install libdb-dev m4

ENV DEBIAN_FRONTEND=noninteractive
ENV DEBIAN_PRIORITY=critical
ENV MYDESTINATION=$MYDESTINATION
ENV RELAYHOST=$RELAYHOST

RUN apt --yes --quiet --option Dpkg::Options::=--force-confold --option Dpkg::Options::=--force-confdef install postfix

RUN sed -i "s/^smtpd_banner = \$myhostname/smtpd_banner = SMTP Garden $MYDESTINATION container -/" /etc/postfix/main.cf
RUN sed -i "s/^mydestination = .*/mydestination = /" /etc/postfix/main.cf
RUN sed -i "s/^relayhost = /relayhost = [$RELAYHOST]:25/" /etc/postfix/main.cf
RUN sed -i 's|^mynetworks = |mynetworks = 172.0.0.0/8 |' /etc/postfix/main.cf
RUN sed -i '$ a maillog_file = /dev/stdout' /etc/postfix/main.cf

RUN sed -i '/^smtp/s/y/n/' /etc/postfix/master.cf

CMD ["postfix", "start-fg"]
