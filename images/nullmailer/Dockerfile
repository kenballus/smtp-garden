FROM smtp-garden-soil:latest

# Development environment
RUN apt -y update && apt -y upgrade \
  && apt -y --no-install-recommends install automake \
  && git clone --recurse-submodules 'https://github.com/bruceg/nullmailer.git' \
  && groupadd nullmail \
  && useradd -g nullmail nullmail
WORKDIR /app/nullmailer
ARG APP_VERSION
RUN git checkout "$APP_VERSION"
# patch for segfault bug: (should be fixed a/o 2024-11-03 commit 79a8a45
#  && sed -i 's/extern const char cli_program\[\] = "nullmailer-smtpd";/extern const char* cli_program = "nullmailer-smtpd";/' /app/nullmailer/src/smtpd.cc

# Build
RUN sh ./autogen.sh \
  && ./configure \
  && make \
  && make install install-root
COPY start-nullmailer.sh /app/

# Configure
ARG RELAYHOST
RUN echo "${RELAYHOST} smtp" > /usr/local/etc/nullmailer/remotes \
  && echo "smtp-garden-nullmailer" > /usr/local/etc/nullmailer/me \
  && chmod +x /app/start-nullmailer.sh

# Go
CMD ["/app/start-nullmailer.sh", "25"]

# Alternate invocation, without signal handling:
#CMD nullmailer-send & nc -lk -p 25 -c nullmailer-smtpd

