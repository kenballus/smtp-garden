FROM smtp-garden-soil:latest

# Development environment config
ARG APP_VERSION
RUN apt -y update && apt -y upgrade &&\
  apt -y install libpcre2-dev libdb-dev libssl-dev libfile-fcntllock-perl pkg-config &&\
  git clone 'https://github.com/Exim/exim'
RUN useradd exim

# Build
RUN cd exim && git checkout $APP_VERSION && cd src && mkdir Local && cp src/EDITME Local/Makefile && sed -i -e 's/^EXIM_USER=/EXIM_USER=exim/' -e 's/^# USE_OPENSSL=/USE_OPENSSL=/' -e 's/# USE_OPENSSL_PC=/USE_OPENSSL_PC=/' Local/Makefile && make -j$(nproc) && make install

# Configure
ADD configure /usr/exim/
ARG RELAYHOST=echo
RUN sed -i "s/__RELAYHOST__/$RELAYHOST/" /usr/exim/configure

# Go
CMD ["/usr/exim/bin/exim", "-bdf"]
