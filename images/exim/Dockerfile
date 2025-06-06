FROM smtp-garden-soil:latest

# Dev environment config
RUN apt -y update && apt -y upgrade \
  && apt -y --no-install-recommends install libpcre2-dev libdb-dev libssl-dev libfile-fcntllock-perl pkg-config \
  && git clone --recurse-submodules 'https://github.com/Exim/exim' \
  && useradd exim

# Build
ARG APP_VERSION
RUN cd exim \
  && git checkout "$APP_VERSION" \
  && cd src \
  && mkdir Local \
  && cp src/EDITME Local/Makefile \
  && sed -i -e 's/^EXIM_USER=/EXIM_USER=exim/' -e 's/^# USE_OPENSSL=/USE_OPENSSL=/' \
       -e 's/^# USE_OPENSSL_PC=/USE_OPENSSL_PC=/' -e 's/^# SUPPORT_MAILDIR=/SUPPORT_MAILDIR=/' \
       -e 's/# APPENDFILE_MODE=0600/APPENDFILE_MODE=0666/' Local/Makefile \
  && make -j$(nproc) \
  && make install
  # was up above, but moved into single sed line:
  #&& sed -i 's/# APPENDFILE_MODE=0600/APPENDFILE_MODE=0666/' /app/exim/src/src/EDITME \

# Configure
COPY configure /usr/exim/
COPY smtp-garden-domains /etc/smtp-garden-domains
COPY lmtp-garden-domains /etc/lmtp-garden-domains
ARG RELAYHOST
RUN sed -i "/ROUTER_RELAY_HOST/s/__RELAYHOST__/${RELAYHOST}/" /usr/exim/configure
#  && touch /etc/smtp-garden-domains

# Go
COPY start-exim.sh /app/start.sh
CMD ["/app/start.sh"]
