FROM smtp-garden-soil:latest

# Development environment config
ARG APP_VERSION=master
ARG RELAYHOST=echo
RUN apt -y update && apt -y upgrade \
  && apt -y install automake libtool gettext texinfo pkg-config libgnutls28-dev \
  && git clone https://git.marlam.de/git/msmtp.git
# Build
RUN cd msmtp \
  && git checkout $APP_VERSION \
  && autoreconf -i \
  && ./configure \
  && make \
  && make install \
# Configure
  && printf "account default\nhost ${RELAYHOST}\n" > /usr/local/etc/msmtprc

COPY start.sh .
RUN chmod +x start.sh
 
# Go
# Workaround for msmtpd not aware of incoming network connections:
CMD nc -lk -p 25 -c 'msmtpd --inetd'

# Preferred, if bug can be fixed:
#CMD ["./start.sh", "25"]

