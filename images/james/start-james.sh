#!/bin/bash
# By Malcolm Schongalla - SMTP Garden Apache James
# Version 1

# Why this script? Because starting James from a script will block SIGTERM

finished=false
ready=false

# Signal handling
stop_james()
{
    echo '[start-james] TERM or INT received...'
    pkill -15 java > /dev/null
    finished=true
}

trap 'stop_james' TERM INT

echo '[start-james] starting...'
cd /app/james
java --enable-preview --add-modules jdk.incubator.vector \
     -javaagent:/app/james/james-server-jpa-app.lib/openjpa-4.0.0.jar \
     -Dlogback.configurationFile=/app/james/conf/logback.xml \
     -Dworking.directory=/app/james \
     --enable-native-access=ALL-UNNAMED \
     -jar /app/james/james-server-jpa-app.jar &

# Wait for the admin server to start before we can add local users
# Should take about 7 seconds on appleseed
# UNFORTUNATELY HEALTHCECK IS BROKEN FOR SOME REASON
#while ! $ready; do
#    sleep 1
#    curl -XGET http://localhost:8000/healthcheck >/dev/null &2>1
#    if [ $? -eq 0]; then
#        ready=true
#    fi
#done
sleep 10

echo '[start-james] online ...presumably'

# Add local users. Assumes Dockerfile took care of +x james-cli.sh
GETAUTH=$(cat /app/james/conf/jmxremote.password)
# should assert $?=0 here...
read UNAME PWORD <<< "$GETAUTH"
/app/james-project/server/apps/spring-app/target/appassembler/bin/james-cli.sh --host localhost --username $UNAME --password $PWORD AddUser user1 digiheals
/app/james-project/server/apps/spring-app/target/appassembler/bin/james-cli.sh --host localhost --username $UNAME --password $PWORD AddUser user2 digiheals

# Wait for TERM signal
while ! $finished; do
    pgrep java > /dev/null
    if [ $? -ne 0 ]; then
        echo '[start-james] james unexpectedly quit'
        exit 2
    fi
    sleep 1
done

# Confirm it's exited, or die trying
sleep 1
pgrep java > /dev/null
if [ $? -eq 0 ]; then
    echo '[start-james] sending SIGKILL to james'
    pkill -9 java
    exit 3
fi
