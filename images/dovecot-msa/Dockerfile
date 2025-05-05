FROM smtp-garden-soil:latest

# Dev environment
RUN apt -y update && apt -y upgrade \
  && apt -y install --no-install-recommends wget autoconf automake bison flex libssl-dev libtool pkg-config gettext pandoc xz-utils \
  && git clone --recurse-submodules https://github.com/dovecot/core.git
WORKDIR /app/core
ARG APP_VERSION
RUN git checkout $APP_VERSION

# Build
RUN ./autogen.sh \
  && ./configure --enable-maintainer-mode \
  && make -j"$(nproc)"\
  && make install

# Configure
RUN groupadd dovecot && useradd -g dovecot dovecot \
  && groupadd dovenull && useradd -g dovenull dovenull \
  && touch /var/log/dovecot.log \
  && touch /var/log/dovecot-info.log \
  && chown dovecot:dovecot /var/log/dovecot.log /var/log/dovecot-info.log

ARG RELAYHOST
COPY dovecot.conf /usr/local/etc/dovecot/dovecot.conf
RUN sed -i "s/__RELAYHOST__/${RELAYHOST}/" /usr/local/etc/dovecot/dovecot.conf

# Go
COPY start-dovecot.sh /app/start-dovecot.sh
CMD ["/app/start-dovecot.sh"]

