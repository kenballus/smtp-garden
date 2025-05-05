FROM smtp-garden-soil:latest

RUN apt -y update && apt -y upgrade \
  && apt -y --no-install-recommends install python3-setuptools \
  && git clone --recurse-submodules 'https://github.com/aio-libs/aiosmtpd'

ARG APP_VERSION
RUN cd aiosmtpd \
  && git checkout "$APP_VERSION" \
  && python3 setup.py install

# Configure
COPY relay-only.py /app
COPY start-aio.sh /app
COPY server.py /app
COPY config.py /app
ARG RELAYHOST
RUN sed -i "/^relay_host/s/__RELAYHOST__/${RELAYHOST}/" config.py
WORKDIR /app

# Start server with local Maildir delivery:
CMD ["/app/start-aio.sh"]

# Start "relay-only" server (no Maildir delivery):
#CMD ["python3", "relay-only.py"]
