FROM smtp-garden-soil:latest

ARG APP_VERSION
ARG MYDESTINATION=postfix
ENV MYDESTINATION=$MYDESTINATION

COPY patch.diff /app/

# Dev environment
RUN apt -y update && apt -y upgrade \
  && apt -y install --no-install-recommends libdb-dev libnsl-dev m4 \
  && cd /app \
  && git clone --recurse-submodules 'https://github.com/vdukhovni/postfix' \
# Build
  && cd /app/postfix \
  && git checkout "$APP_VERSION" \
  && patch -p1 < /app/patch.diff \
  && cd /app/postfix/postfix \
  && make -j$(nproc) OPT='-fsanitize=undefined -lnsl' \
  && useradd postfix \
  && groupadd postdrop \
  && make install POSTFIX_INSTALL_OPTS=-non-interactive

# Configure
COPY main.cf /etc/postfix/
COPY master.cf /etc/postfix/
COPY relay_domains /etc/postfix/
COPY transport /etc/postfix/
COPY recipient_canonical /etc/postfix/
ARG RELAYHOST
ENV RELAYHOST=$RELAYHOST
RUN chmod 644 /etc/postfix/main.cf \
  && chmod 644 /etc/postfix/master.cf \
  && sed -i "s/__RELAYHOST__/$RELAYHOST/" /etc/postfix/main.cf \
  && touch /etc/aliases \
  && /usr/bin/newaliases \
  && postmap /etc/postfix/transport \
  && postmap /etc/postfix/relay_domains \
  && postmap /etc/postfix/recipient_canonical

# Establish local email targets
RUN adduser user1 && adduser user2
#RUN useradd --create-home user1 && useradd --create-home user2 \
#  && usermod --append --groups users user1 \
#  && usermod --append --groups users user2 \
#  && chgrp -R users /home/user1 \
#  && chgrp -R users /home/user2 \
#  && chmod -R 770 /home/user1 \
#  && chmod -R 770 /home/user2 \
#  && usermod -a -G users exim

CMD ["postfix", "start-fg"]
