FROM smtp-garden-soil:latest

RUN apt -y update && apt -y upgrade && apt -y install libpcre2-dev libdb-dev libssl-dev libfile-fcntllock-perl pkg-config && git clone 'https://github.com/Exim/exim'

RUN useradd exim

ARG APP_VERSION
RUN cd exim && git checkout $APP_VERSION && cd src && mkdir Local && cp src/EDITME Local/Makefile && sed -i -e 's/^EXIM_USER=/EXIM_USER=exim/' -e 's/^# USE_OPENSSL=/USE_OPENSSL=/' -e 's/# USE_OPENSSL_PC=/USE_OPENSSL_PC=/' Local/Makefile && make -j$(nproc) && make install

RUN sed -i -e 's/^hostlist   relay_from_hosts = localhost/hostlist   relay_from_hosts = */' -e 's/^domainlist relay_to_domains =/domainlist relay_to_domains = echo/' /usr/exim/configure

CMD /usr/exim/bin/exim -bdf
