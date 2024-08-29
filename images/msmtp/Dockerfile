FROM smtp-garden-soil:latest

# Development environment config
ARG APP_VERSION
RUN apt -y update && apt -y upgrade \
  && apt -y --no-install-recommends install automake libtool gettext texinfo pkg-config libgnutls28-dev \
  && git clone https://git.marlam.de/git/msmtp.git \
  && cd msmtp \
# Build
  && git checkout --recurse-submodules "$APP_VERSION" \
  && autoreconf -i \
  && ./configure \
  && make \
  && make install
# Configure

COPY start.sh .
ARG RELAYHOST
RUN printf "account default\nhost ${RELAYHOST}\n" > /usr/local/etc/msmtprc \
  && chmod +x start.sh
 
# Go (port number "25" is optional and can be changed)
CMD ["./start.sh", "25"]

# Alternate invocation by ncat:
#CMD nc -lk -p 25 -c 'msmtpd --inetd'
