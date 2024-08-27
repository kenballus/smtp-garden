FROM smtp-garden-soil:latest

# Development environment config
ARG APP_VERSION=master
ARG RELAYHOST=echo
RUN apt -y update && apt -y upgrade \
  && apt -y install automake \
  && git clone 'https://github.com/bruceg/nullmailer.git' \
  && groupadd nullmail \
  && useradd -g nullmail nullmail 

# Build
RUN cd nullmailer \
  && git checkout $APP_VERSION \
  && sh ./autogen.sh \
  && ./configure \
  && make \
  && make install install-root

# Configure
RUN echo "smtp-garden-nullmailer" > /usr/local/etc/nullmailer/me \
  && echo "${RELAYHOST} smtp" > /usr/local/etc/nullmailer/remotes

# Go
CMD nullmailer-send & nc -lk -p 25 -c nullmailer-smtpd

