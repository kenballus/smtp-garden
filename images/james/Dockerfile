FROM smtp-garden-soil:malcolm

# default pw for keystore is james72laBalle, a legacy James thing

# Dev config
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV PATH=${PATH}:${JAVA_HOME}/bin
RUN echo "deb http://deb.debian.org/debian unstable main non-free contrib" >> /etc/apt/sources.list && \
    echo "Package: *" >> /etc/apt/preferences && \
    echo "Pin: release a=stable" >> /etc/apt/preferences && \
    echo "Pin-Priority: 900" >> /etc/apt/preferences && \
    echo "Package: *" >> /etc/apt/preferences && \
    echo "Pin: release a=unstable" >> /etc/apt/preferences && \
    echo "Pin-Priority: 50" >> /etc/apt/preferences
RUN apt -y update && apt -y upgrade && apt -y install unzip openjdk-11-jdk maven libdb-dev m4 libc6 libc6-dev

# Unpack
WORKDIR /app
ADD https://dlcdn.apache.org/james/server/3.8.1/james-project-3.8.1-source-release.zip /app/james-project-3.8.1-source-release.zip
RUN unzip james-project-3.8.1-source-release.zip
RUN rm /app/james-project-3.8.1-source-release.zip
WORKDIR /app/james-project

# Build; Skip executing tests, but you can't skip building them (with `-Dmaven.skip.tests=true`) or compilation fails
RUN mvn -T 4 -DskipTests clean install 

# Deploy jars and cleanup
RUN mkdir /app/james && cp -r /app/james-project/server/apps/jpa-app/target/james-server-jpa-app.* /app/james/
ADD conf /app/james/conf/
RUN rm -r /app/james-project

# Go
WORKDIR /app/james
CMD ["java", \
     "-javaagent:/app/james/james-server-jpa-app.lib/openjpa-3.2.0.jar", \
     "-Dlogback.configurationFile=/app/james/conf/logback.xml", \
     "-Djdk.tls.ephemeralDHKeySize=2048", \
     "-Dworking.directory=/app/james", \
     "-jar", "/app/james/james-server-jpa-app.jar"]