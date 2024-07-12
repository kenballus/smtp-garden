FROM smtp-garden-soil:latest

ARG APP_VERSION="master"
ARG MYDESTINATION=postfix
ARG RELAYHOST=echo

ENV MYDESTINATION=$MYDESTINATION
ENV RELAYHOST=$RELAYHOST

COPY patch.diff /app/

RUN apt -y update && apt -y upgrade \
 && apt -y install libdb-dev libnsl-dev m4 \
 && cd /app \
 && git clone 'https://github.com/vdukhovni/postfix' \
 && cd /app/postfix \
 && git checkout $APP_VERSION \
 && patch -p1 < /app/patch.diff

WORKDIR /app/postfix/postfix

RUN make -j$(nproc) OPT='-fsanitize=undefined -lnsl' \
 &&  useradd postfix && groupadd postdrop
RUN make install POSTFIX_INSTALL_OPTS=-non-interactive

# Option A- Install pre-written config files:
#COPY main.cf /etc/postfix/
#COPY master.cf /etc/postfix/

# Option B- Modifying original config files in place:
RUN sed -i "s/^smtpd_banner = \$myhostname/smtpd_banner = SMTP Garden $MYDESTINATION container -/" /etc/postfix/main.cf
RUN sed -i "s/^mydestination = .*/mydestination = /" /etc/postfix/main.cf
RUN sed -i "s/^relayhost = /relayhost = [$RELAYHOST]:25/" /etc/postfix/main.cf
RUN sed -i 's|^mynetworks = |mynetworks = 172.0.0.0/8 |' /etc/postfix/main.cf
RUN sed -i '$ a maillog_file = /dev/stdout' /etc/postfix/main.cf
RUN sed -i '/^smtp/s/y/n/' /etc/postfix/master.cf

CMD ["postfix", "start-fg"]
