FROM smtp-garden-soil:latest

ARG APP_VERSION

RUN apt -y update && apt -y upgrade \
  && apt -y --no-install-recommends install python3-setuptools \
  && git clone --recurse-submodules 'https://github.com/aio-libs/aiosmtpd' \
  && cd aiosmtpd \
  && git checkout "$APP_VERSION" \
  && python3 setup.py install

COPY relay.py .
ARG RELAYHOST
RUN sed -i "/^relay_host/s/__RELAYHOST__/${RELAYHOST}/" relay.py

CMD ["python3", "relay.py"]
