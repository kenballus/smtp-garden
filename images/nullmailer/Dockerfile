FROM smtp-garden-soil:latest

# Development environment config
ARG APP_VERSION=master
ARG RELAYHOST=echo
RUN apt -y update && apt -y upgrade \
  && apt -y install automake \
  && git clone 'https://github.com/bruceg/nullmailer.git' \
  && groupadd nullmail \
  && useradd -g nullmail nullmail \
# Build
  && cd nullmailer \
  && git checkout $APP_VERSION \
  && sh ./autogen.sh \
  && ./configure \
  && make \
  && make install install-root \
# Configure
  && echo "smtp-garden-nullmailer" > /usr/local/etc/nullmailer/me \
  && echo "${RELAYHOST} smtp" > /usr/local/etc/nullmailer/remotes

COPY start.sh .
RUN chmod +x start.sh

# Go
CMD ["./start.sh", "25"]

# Alternate invocation, without signal handling:
#CMD nullmailer-send & nc -lk -p 25 -c nullmailer-smtpd

