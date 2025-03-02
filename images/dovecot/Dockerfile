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
  && make \
  && make install

# Configure
RUN groupadd dovecot && useradd -g dovecot dovecot \
  && groupadd dovenull && useradd -g dovenull dovenull \
  && useradd user1 && useradd user2 \
  && mkdir -p /home/user1/Maildir/cur && mkdir /home/user1/Maildir/new && mkdir /home/user1/Maildir/tmp && chown -R user1:user1 /home/user1 \
  && mkdir -p /home/user2/Maildir/cur && mkdir /home/user2/Maildir/new && mkdir /home/user2/Maildir/tmp && chown -R user2:user2 /home/user2 \
  && touch /var/log/dovecot.log \
  && touch /var/log/dovecot-info.log \
  && chown dovecot:dovecot /var/log/dovecot.log /var/log/dovecot-info.log
#  && groupadd vmail && useradd -g vmail -m vmail \
#  && mkdir /home/vmail/Maildir && chown vmail:vmail /home/vmail/Maildir \
#  && useradd -g users -m user1 && useradd -g users -m user2 \
#  && chown vmail:vmail /var/log/dovecot.log /var/log/dovecot-info.log

ARG RELAYHOST
COPY dovecot.conf /usr/local/etc/dovecot/dovecot.conf
RUN sed -i "s/__RELAYHOST__/${RELAYHOST}/" /usr/local/etc/dovecot/dovecot.conf

# Go
CMD ["dovecot", "-F"]

