#!/bin/bash
# By Malcolm Schongalla - SMTP Garden Apache James
# Version 1.1 - restores UID:GID
# Version 1.0 - original

finished=false
ready=false
self="[start-james]"

# Signal handling
stop_james()
{
    echo "$self TERM or INT received..."
    pkill -15 java > /dev/null
    finished=true
}

trap 'stop_james' TERM INT

echo "$self checking for host UID:GID (from host .env file)..."
has_UID=false
if [ -n "${HOST_UID+x}" ] &&
   [ "$HOST_UID" -eq "$HOST_UID" 2>/dev/null ] &&
   [ "$HOST_UID" -ge 1000 ]; then
    has_UID=true
    echo "$self - UID detected: $HOST_UID"
else
    echo "$self - No UID detected. Home dirs won't be reassigned at exit."
fi

has_GID=false
if [ -n "$HOST_GID" ] && [ "$HOST_GID" -eq "$HOST_GID" ] && [ "$HOST_GID" -ge 1000 ] 2>/dev/null; then
    has_GID=true
    echo "$self - host GID detected: $HOST_GID"
else
    echo "$self - No host GID detected. Home dirs won't be reassigned at exit."
fi

if $has_UID && $has_GID; then
        echo "$self - Will attempt home dir reassignment upon exit."
fi

# Because ownership of home folders may have changed after previous sessions
echo "$self preparing /home tree..."
chown root:root /home
chown -R user1:user1 /home/user1
chown -R user2:user2 /home/user2
chown root:root /app/james/mail/inbox

echo "$self starting..."
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

echo "$self online ...presumably"

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
        echo "$self james unexpectedly quit"
        exit 2
    fi
    sleep 1
done

# Confirm it's exited, or die trying
exitcode=0
sleep 1
pgrep java > /dev/null
if [ $? -eq 0 ]; then
    echo "$self sending SIGKILL to james"
    pkill -9 java
    exitcode=4
fi

if $has_UID && $has_GID; then
    echo "$self reassigning home folder ownership..."
    chown -R "$HOST_UID":"$HOST_GID" /home
    chown -R "$HOST_UID":"$HOST_GID" /app/james/mail/inbox
fi

exit $exitcode
