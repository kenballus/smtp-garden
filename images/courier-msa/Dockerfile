FROM smtp-garden-soil:latest

ARG RELEASE_VER="1.3.13"

# Dev environment & dependencies
WORKDIR /app
RUN apt -y update && apt -y upgrade \
  && apt -y --no-install-recommends install autoconf automake bzip2 \
     docbook docbook-xml docbook-xsl \
     elinks expect gettext gpg libcourier-unicode8 libcourier-unicode-dev \
     libgdbm-dev libidn12 libidn2-dev libldap2-dev libltdl-dev \
     libmariadb-dev libpam0g-dev libpcre2-dev libperl-dev libpq-dev \
     libsqlite3-dev libtool libz-dev pcre2-utils pkg-config sysconftool \
     tidy w3c-sgml-lib wget xsltproc socat \
  && chmod 777 /app

# Set up authlib from scratch. Apt repo doesn't have everything necessary.
USER user1
ARG AUTHLIB_VER="0.72.3"
RUN cd /app \
  && wget -O courier-authlib-${AUTHLIB_VER}.tar.bz2 https://sourceforge.net/projects/courier/files/authlib/${AUTHLIB_VER}/courier-authlib-${AUTHLIB_VER}.tar.bz2/download \
  && tar -xvf courier-authlib-${AUTHLIB_VER}.tar.bz2 \
  && cd courier-authlib-${AUTHLIB_VER} \
  && ./configure --with-mailuser=courier, --with-mailgroup=courier \
  && make -j"$(nproc)"
USER root
RUN cd /app/courier-authlib-${AUTHLIB_VER} \
  && useradd -r courier \
  && make install \
  && make install-configure

# Unpack & build
USER user1
RUN cd /app \
  && wget -O courier-${RELEASE_VER}.tar.bz2 https://sourceforge.net/projects/courier/files/courier/${RELEASE_VER}/courier-${RELEASE_VER}.tar.bz2/download \
  && tar -xvf courier-${RELEASE_VER}.tar.bz2 \
  && cd courier-${RELEASE_VER} \
  && ./configure --with-notice=unicode --with-mailuser=courier --with-mailgroup=courier \
  && make -j"$(nproc)"
USER root
RUN cd /app/courier-${RELEASE_VER} \
  && make install && make install-configure

# Configure 
COPY ./conf /usr/lib/courier/etc
ARG RELAYHOST
RUN cd /usr/lib/courier/etc \
  && sed -i "s/__RELAYHOST__/${RELAYHOST}/" /usr/lib/courier/etc/esmtproutes \
  && sed -i "s/daemons=5/daemons=1/" /usr/local/etc/authlib/authdaemonrc \
  && sed -i "s/DEBUG_LOGIN=0/DEBUG_LOGIN=2/" /usr/local/etc/authlib/authdaemonrc \
  && sed -i '/^authmodulelist/ s/"authuserdb authpam authpgsql authldap authsqlite authcustom authpipe"/"authpam"/' /usr/local/etc/authlib/authdaemonrc \
  && /usr/lib/courier/sbin/makesmtpaccess-msa \
  && /usr/lib/courier/sbin/makeacceptmailfor \
  && /usr/lib/courier/sbin/makesmtpaccess \
  && /usr/lib/courier/sbin/makealiases \
  && /usr/lib/courier/sbin/makesmtpaccess

# Go
COPY start-courier.sh /app/start-courier.sh
WORKDIR /app
CMD ["/app/start-courier.sh"]
