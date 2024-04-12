FROM smtp-garden-soil:latest

RUN apt -y update && apt -y upgrade && apt -y install libdb-dev m4 && git clone 'https://github.com/vdukhovni/postfix'

COPY patch.diff .

# Note that Postfix doesn't use a VCS for development. We are pulling code in from this git mirror only for the sake of uniformity with other targets.
ARG APP_VERSION
RUN cd postfix && git checkout $APP_VERSION && patch -p1 < /app/patch.diff && cd postfix && make -j$(nproc) OPT='-fsanitize=undefined' && useradd postfix && groupadd postdrop && make install POSTFIX_INSTALL_OPTS=-non-interactive

RUN sed -i 's/^#relayhost = $mydomain/relayhost = [echo]:25/' /etc/postfix/main.cf

CMD postfix start && sleep infinity
