FROM smtp-garden-soil:latest

ARG APP_VERSION

# Dev environment
RUN apt -y update && apt -y upgrade \
    && apt -y --no-install-recommends install unzip openjdk-21-jdk maven libdb-dev m4 libc6 libc6-dev \
    && cd /app \
    && git clone --recurse-submodules https://github.com/apache/james-project.git \
    && cd /app/james-project \
    && git checkout "$APP_VERSION"

# Update dependencies
RUN sed -i '/<dependencies>/a \
    <dependency>\n\
        <groupId>org.hsqldb</groupId>\n\
        <artifactId>hsqldb</artifactId>\n\
        <version>2.7.2</version>\n\
        <scope>compile</scope>\n\
    </dependency>' /app/james-project/server/apps/jpa-app/pom.xml

# Fix broken hardlink
RUN sed -i "s|conf/jvm.properties|/app/james/conf/jvm.properties|" \
    /app/james-project/server/container/guice/common/src/main/java/org/apache/james/ExtraProperties.java 

# Build
RUN cd /app/james-project && mvn -T $(nproc) -Dsort.skip=true -DskipTests clean install \
    && mkdir /app/james \
    && cp -r /app/james-project/server/apps/jpa-app/target/james-server-jpa-app.* /app/james/

# Clean up a bit - uncomment these lines for production container
#RUN rm -r /app/james-project \
#    && apt -y purge openjdk-21-jdk && apt -y autoremove && apt -y install openjdk-21-jre \
#    && rm -r /root/.m2

# Configure
ARG RELAYHOST
ADD conf /app/james/conf
RUN sed -i "s/<gateway>__RELAYHOST__/<gateway>${RELAYHOST}/" /app/james/conf/mailetcontainer.xml

# In the future, also dynamically configure the list of peer hosts in mailetcontainer.xml's "relay-to-peer" matcher

# Set up local recepient accounts
RUN useradd --create-home user1 && useradd --create-home user2 \
  && usermod --append --groups users user1 \
  && usermod --append --groups users user2 \
  && mkdir -p /home/user1 \
  && mkdir -p /home/user2 \
  && chown -R user1:users /home/user1 \
  && chown -R user2:users /home/user2 \
#  && chgrp -R users /home/user1 \
#  && chgrp -R users /home/user2 \
  && chmod -R 770 /home/user1 \
  && chmod -R 770 /home/user2

# Go
CMD ["java", \
     "--enable-preview", \
     "--add-modules", "jdk.incubator.vector", \
     "-javaagent:/app/james/james-server-jpa-app.lib/openjpa-4.0.0.jar", \
     "-Dlogback.configurationFile=/app/james/conf/logback.xml", \
     "-Dworking.directory=/app/james", \
     "--enable-native-access=ALL-UNNAMED", \
     "-jar", "/app/james/james-server-jpa-app.jar"]
