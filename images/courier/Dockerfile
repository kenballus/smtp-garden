FROM smtp-garden-soil:latest

ARG RELEASE_VER="1.3.13"

# Dev environment & dependencies
WORKDIR /app
RUN apt -y update && apt -y upgrade \
  && apt -y --no-install-recommends install autoconf automake bzip2 \
     courier-authlib courier-authlib-dev docbook docbook-xml docbook-xsl \
     elinks expect gettext gpg libcourier-unicode4 libcourier-unicode-dev \
     libgdbm-dev libidn12 libidn2-dev libldap2-dev libltdl-dev \
     libmariadb-dev libpam0g-dev libpcre2-dev libperl-dev libpq-dev \
     libsqlite3-dev libtool libz-dev pcre2-utils pkg-config sysconftool \
     tidy w3c-sgml-lib wget xsltproc \
  && chmod 777 /app

# Local user inboxes
RUN adduser user1 && adduser user2 \
  && mkdir -p /home/user1/Maildir/{new,cur,tmp} \
  && printf "| /usr/bin/id >ID\n| /usr/bin/env >ENV\n" > /home/user1/Maildir/.courier \
  && chown -R user1:user1 /home/user1/Maildir \
  && chmod -R 744 /home/user1/Maildir \
  && mkdir -p /home/user2/Maildir/{new,cur,tmp} \
  && printf "| /usr/bin/id >ID\n| /usr/bin/env >ENV\n" > /home/user2/Maildir/.courier \
  && chown -R user2:user2 /home/user2/Maildir \
  && chmod -R 744 /home/user2/Maildir

# Unpack & build
USER user1
RUN cd /app \
  && wget -O courier-${RELEASE_VER}.tar.bz2 https://sourceforge.net/projects/courier/files/courier/${RELEASE_VER}/courier-${RELEASE_VER}.tar.bz2/download \
  && tar -xvf courier-${RELEASE_VER}.tar.bz2 \
  && cd courier-${RELEASE_VER} \
  && ./configure --with-notice=unicode \
  && make
USER root
RUN cd /app/courier-${RELEASE_VER} \
  && make install && make install-configure

# Configure 
COPY ./courierconf.tar.gz /usr/lib/courier/etc/courierconf.tar.gz
RUN cd /usr/lib/courier/etc \
  && tar -xvf courierconf.tar.gz \
  && /usr/lib/courier/sbin/makesmtpaccess-msa \
  && /usr/lib/courier/sbin/makeacceptmailfor \
  && /usr/lib/courier/sbin/makesmtpaccess \
  && /usr/lib/courier/sbin/makealiases \
  && /usr/lib/courier/sbin/makesmtpaccess

# Go
COPY ./start-courier.sh /app/start-courier.sh
WORKDIR /app
CMD ["./start-courier.sh"]



##################
# Historical attempts
################

#USER root
# skip manually building the support libraries and tools
# Where I left off: exploring the courier-debuild script
# - Inspect what it does to see if I can reproduce it in Dockerfile or if it's a red herring
# - try to get it to run replacing 'readlink /usr/bin/gcc' with 'readlink /etc/alternatives/gcc' or something like that
# Also, see if there's a good way to search the Courier-MTA mailing list for past questions.

#
# Set up libraries
#USER courier
#RUN cd /app \
#  && git clone --recurse-submodules 'https://github.com/svarshavchik/courier.git' \
#  && cd /app/courier \
#  && git clone --recurse-submodules 'https://github.com/svarshavchik/courier-libs.git' libs

# Build and install sysconftool
#RUN cd /app/courier/sysconftool \ 
#  && ln -s /app/courier/libs \
#  && sh autobloat \
#  && ./configureb
#USER root
#RUN cd /app/courier/sysconftool \
#  && make && make install

# Build and install courier-unicode
# installs, but does not seem to install macros needed by courier-authlib and others!
# /app/courier/courier/libs/unicode/courier-unicode-version.m4.in
# contains the macro definition, I think.  Why doesn't this get included??
#USER courier
#RUN cd /app/courier/libs/unicode \
#  && sh ./autobloat && ./configure
#USER root
#RUN cd /app/courier/sysconftool/libs/unicode \
#  && make && make install
#RUN apt -y install libcourier-unicode4

# Build and install courier-authlib
# FAILS because courier-unicode macros are not fully installed
#USER courier
#RUN cd /app/courier/courier-authlib \
#  && ln -s /app/courier/libs
#  &&  sh ./autobloat \
#  && ./configure
#USER root
#RUN cd /app/courier/courier-authlib \
#  && make && make install && make install-configure

#WORKDIR /app/courier/courier
#RUN git clone --recurse-submodules 'https://github.com/svarshavchik/courier-libs.git' libs
#RUN sh ./autobloat

#RUN sh ./autobloat \
#  && ./configure \
#  && make && make install \
#  && cd /app/courier-libs/unicode \
#  && sh ./autobloat \
#  && ./configure \
#  && make & make install
#WORKDIR /app/courier/courier
#RUN sh ./autobloat \
#  && ./configure
# added AC_CONFIG_MACRO_DIRS([m4]) to configure.ac
# cut out libltdl


# Build
#ARG APP_VERSION="master"
#ARG COURIER_LIBS="https://github.com/svarshavchik/courier-libs.git"
#ARG MAKEFLAGS="-j $(nproc)"
#WORKDIR /app/courier
#RUN git checkout "$APP_VERSION"
#run sh INSTALLME courier https://github.com/svarshavchik/courier-libs.git 

#USER courier
#WORKDIR /app/courier
#RUN configure
#USER root
#RUN make
#RUN make check
#RUN make install
#RUN make install-configure

# Configure
#ARG RELAYHOST
#RUN sed -i "/ROUTER_RELAY_HOST/s/__RELAYHOST__/${RELAYHOST}/" /usr/exim/configure

# Go
