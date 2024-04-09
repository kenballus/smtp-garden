FROM smtp-garden-soil:latest

RUN apt -y update && apt -y upgrade && apt -y install libdb-dev m4 && git clone 'https://github.com/vdukhovni/postfix'

# Note that Postfix doesn't use a VCS for development. We are pulling code in from this git mirror only for the sake of uniformity with other targets.
ARG APP_VERSION
RUN cd postfix/postfix && git checkout $APP_VERSION && make -j$(nproc) && useradd postfix && groupadd postdrop && make install POSTFIX_INSTALL_OPTS=-non-interactive

CMD postfix start && sleep infinity
