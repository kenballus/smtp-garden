FROM smtp-garden-soil:latest

ARG APP_VERSION

# Dev environment
RUN apt -y update && apt -y upgrade \
    && apt -y --no-install-recommends install unzip openjdk-21-jdk maven libdb-dev m4 libc6 libc6-dev \
    && cd /app \
    && git clone --recurse-submodules https://github.com/apache/james-project.git \
# Build
    && cd /app/james-project \
    && git checkout "$APP_VERSION" \
    && mvn -T $(nproc) -DskipTests clean install \
    && mkdir /app/james \
    && cp -r /app/james-project/server/apps/jpa-app/target/james-server-jpa-app.* /app/james/

# Configure & clean up
ARG RELAYHOST
ADD conf /app/conf
RUN mkdir /app/james/conf \
    && cp /app/conf/* /app/james/conf \
    && sed -i "s/<gateway>__RELAYHOST__/<gateway>${RELAYHOST}/" /app/james/conf/mailetcontainer.xml \
    && rm -r /app/james-project \
    && apt -y purge openjdk-21-jdk && apt -y autoremove && apt -y install openjdk-21-jre \
    && rm -r /root/.m2

# Go
CMD ["java", \
     "-javaagent:/app/james/james-server-jpa-app.lib/openjpa-4.0.0.jar", \
     "-Dlogback.configurationFile=/app/james/conf/logback.xml", \
     "-Dworking.directory=/app/james", \
     "-jar", "/app/james/james-server-jpa-app.jar"]
