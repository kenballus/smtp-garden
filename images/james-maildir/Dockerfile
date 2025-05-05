FROM smtp-garden-soil:latest

ARG APP_VERSION

# Dev environment
RUN apt -y update && apt -y upgrade \
    && apt -y --no-install-recommends install unzip openjdk-21-jdk maven libdb-dev m4 libc6 libc6-dev \
    && cd /app \
    && git clone --recurse-submodules https://github.com/apache/james-project.git \
    && cd /app/james-project \
    && git checkout "$APP_VERSION"

# Fix broken hardlink
RUN sed -i "s|conf/jvm.properties|/app/james/conf/jvm.properties|" \
    /app/james-project/server/container/guice/common/src/main/java/org/apache/james/ExtraProperties.java 

# Inject custom Maildir delivery class into source tree
COPY maildir-utils/ToMaildir.java /app/james-project/server/mailet/mailets/src/main/java/org/apache/james/transport/mailets/ToMaildir.java

# Build.  Skip checkstyle, or it will flag the custom mailet.
RUN cd /app/james-project && mvn -T $(nproc) -Dsort.skip=true -DskipTests -Dcheckstyle.skip=true clean install \
    && mkdir /app/james \
    && cp -r /app/james-project/server/apps/jpa-app/target/james-server-jpa-app.* /app/james/

# Clean up a bit - uncomment these lines for production container
#RUN rm -r /app/james-project \
#    && apt -y purge openjdk-21-jdk && apt -y autoremove && apt -y install openjdk-21-jre \
#    && rm -r /root/.m2

# Configure
ARG RELAYHOST
ADD conf /app/james/conf
RUN sed -i "s/<gateway>__RELAYHOST__/<gateway>${RELAYHOST}/" /app/james/conf/mailetcontainer.xml \
  && chmod +x /app/james-project/server/apps/spring-app/target/appassembler/bin/james-cli.sh

# custom Maildir delivery utility
COPY maildir-utils/localdelivery.sh /app/localdelivery.sh
RUN chmod +x /app/localdelivery.sh

# Go
ADD start-james.sh /app/james/start-james.sh
CMD ["/app/james/start-james.sh"]

