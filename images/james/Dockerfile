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
# Clean up a bit
RUN rm -r /app/james-project \
    && apt -y purge openjdk-21-jdk && apt -y autoremove && apt -y install openjdk-21-jre \
    && rm -r /root/.m2

# Configure
ARG RELAYHOST
ADD conf /app/james/conf
# ADD conf /app/conf
#RUN mkdir /app/james/conf \
#    && cp /app/conf/* /app/james/conf \
#    && sed -i "s/<gateway>__RELAYHOST__/<gateway>${RELAYHOST}/" /app/james/conf/mailetcontainer.xml
RUN sed -i "s/<gateway>__RELAYHOST__/<gateway>${RELAYHOST}/" /app/james/conf/mailetcontainer.xml

# In the future, also dynamically configure the list of peer hosts in mailetcontainer.xml's "relay-to-peer" matcher

# Set up local recepient accounts
RUN useradd --create-home user1 && useradd --create-home user2 \
  && usermod --append --groups users user1 \
  && usermod --append --groups users user2 \
  && mkdir -p /home/user1/Maildir/new \
  && mkdir /home/user1/Maildir/cur \
  && mkdir /home/user1/Maildir/tmp \
  && mkdir -p /home/user2/Maildir/new \
  && mkdir /home/user2/Maildir/cur \
  && mkdir /home/user2/Maildir/tmp \
  && chown -R user1:users /home/user1 \
  && chown -R user2:users /home/user2 \
#  && chgrp -R users /home/user1 \
#  && chgrp -R users /home/user2 \
  && chmod -R 770 /home/user1 \
  && chmod -R 770 /home/user2

# Go
CMD ["java", \
     "-javaagent:/app/james/james-server-jpa-app.lib/openjpa-4.0.0.jar", \
     "-Dlogback.configurationFile=/app/james/conf/logback.xml", \
     "-Dworking.directory=/app/james", \
     "-jar", "/app/james/james-server-jpa-app.jar"]
