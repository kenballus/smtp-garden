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
COPY conf /etc/postfix/
ARG RELAYHOST
RUN chmod 644 /etc/postfix/main.cf \
  && chmod 644 /etc/postfix/master.cf \
  && sed -i "s/__RELAYHOST__/$RELAYHOST/" /etc/postfix/main.cf \
  && touch /etc/aliases \
  && /usr/bin/newaliases \
  && postmap /etc/postfix/transport \
  && postmap /etc/postfix/relay_domains \
  && postmap /etc/postfix/recipient_canonical 

# Go
COPY start-postfix.sh /app/start-postfix.sh
CMD ["/app/start-postfix.sh"]
