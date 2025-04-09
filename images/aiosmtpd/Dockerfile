FROM smtp-garden-soil:latest

RUN apt -y update && apt -y upgrade \
  && apt -y --no-install-recommends install python3-setuptools \
  && git clone --recurse-submodules 'https://github.com/aio-libs/aiosmtpd'

ARG APP_VERSION
RUN cd aiosmtpd \
  && git checkout "$APP_VERSION" \
  && python3 setup.py install

# Configure
# Users and Maildirs only required if running server.py option.
RUN useradd user1 && useradd user2 \
  && mkdir -p /home/user1/Maildir/cur && mkdir /home/user1/Maildir/new && mkdir /home/user1/Maildir/tmp && chown -R user1:user1 /home/user1 \
  && mkdir -p /home/user2/Maildir/cur && mkdir /home/user2/Maildir/new && mkdir /home/user2/Maildir/tmp && chown -R user2:user2 /home/user2

COPY relay-only.py /app
COPY start-aio.sh /app
COPY server.py /app
COPY config.py /app
ARG RELAYHOST
RUN sed -i "/^relay_host/s/__RELAYHOST__/${RELAYHOST}/" config.py
WORKDIR /app

# Start server with local user awareness:
CMD ["/app/start-aio.sh"]

# Start "relay-only" server:
#CMD ["python3", "relay-only.py"]
