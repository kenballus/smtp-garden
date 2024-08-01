FROM smtp-garden-soil:latest

ARG RELAYHOST=echo
ARG APP_VERSION=master
ADD conf /app/conf
RUN apt -y update && apt -y upgrade \
    && apt -y install unzip openjdk-21-jdk maven libdb-dev m4 libc6 libc6-dev \
    && cd /app \
    && git clone https://github.com/apache/james-project.git \
    && echo "Building..." \
    && cd /app/james-project \
    && mvn -T $(nproc) -DskipTests clean install \
    && echo "Deploying jars..." \
    && mkdir /app/james \
    && cp -r /app/james-project/server/apps/jpa-app/target/james-server-jpa-app.* /app/james/ \
    && echo "Deploying configs..." \
# Version A: somewhat minimal configuration (loads fast, no activemq log spam)
    && mkdir /app/james/conf \
    && cp /app/conf/* /app/james/conf \
# Version B: default conf files, minimal (warning, James spams the logs. These needs additional editing)
#    && find /app/james-project/server/apps/spring-app/src/main/resources -maxdepth 1 -type f -exec cp -t /app/james/conf {} + \
#    && cp /app/conf/mailetcontainer.xml /app/james/conf \
#    && cp /app/conf/smtpserver.xml /app/james/conf \
#    && cp /app/conf/activemq.properties /app/james/conf \
#    && cp /app/conf/keystore /app/james/keystore \
    && sed -i "s/<gateway>__RELAYHOST__/<gateway>${RELAYHOST}/" /app/james/conf/mailetcontainer.xml \
    && echo "Cleanup..." \
    && rm -r /app/james-project \
# Saves a little bit of space
    && apt -y purge openjdk-21-jdk && apt -y autoremove && apt -y install openjdk-21-jre \
    && rm -r /root/.m2

# Go
WORKDIR /app/james
CMD ["java", \
     "-javaagent:/app/james/james-server-jpa-app.lib/openjpa-4.0.0.jar", \
     "-Dlogback.configurationFile=/app/james/conf/logback.xml", \
     "-Dworking.directory=/app/james", \
     "-jar", "/app/james/james-server-jpa-app.jar"]
