FROM smtp-garden-soil:latest

ARG APP_VERSION=master
ARG RELAYHOST=echo

WORKDIR /app
RUN apt -y update && apt -y upgrade && apt -y install python3-setuptools && git clone 'https://github.com/aio-libs/aiosmtpd'
RUN cd aiosmtpd && git checkout $APP_VERSION && python3 setup.py install

COPY relay.py .
RUN sed -i "/^relay_host/s/__RELAYHOST__/${RELAYHOST}/" relay.py

CMD ["python3", "relay.py"]
