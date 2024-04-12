FROM smtp-garden-soil:latest

RUN apt -y update && apt -y upgrade && apt -y install python3-setuptools && git clone 'https://github.com/aio-libs/aiosmtpd'

ARG APP_VERSION
RUN cd aiosmtpd && git checkout $APP_VERSION && python3 setup.py install

COPY relay.py .

CMD ["python3", "relay.py"]
