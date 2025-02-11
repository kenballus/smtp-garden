FROM smtp-garden-soil:latest

# Dev environment
RUN apt -y update && apt -y upgrade \
  && apt -y install dnsutils iputils-ping \
  && git clone --recurse-submodules git://thekelleys.org.uk/dnsmasq.git

# Build
WORKDIR /app/dnsmasq
ARG APP_VERSION="master"
RUN git checkout $APP_VERSION
RUN make install

# be sure to attach a volume for dnsmasq.conf, if not using compose file
CMD ["dnsmasq", "-k"]
