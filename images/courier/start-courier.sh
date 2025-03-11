#!/bin/bash
# By Malcolm Schongalla - SMTP Garden Apache Courier-MTA
# Version 1

# Use this script until a way to run Courier-MTA in the foreground is established

finished=false
ready=false

# Signal handling
stop_courier()
{
    echo '[start-courier] TERM or INT received...'
    courierlogger -stop -pid=/home/courierlog
    finished=true
}

trap 'stop_courier' TERM INT

echo '[start-courier] starting...'
cd /usr/lib/courier/sbin/

# The -pid flag is not supposed to be a PID. It is supposed to be a file to which syslog messages are saved.
# Putting it in /home conveniently puts it in the Docker volume.

courierlogger -pid=/home/courierlog -name=TestLog -start /usr/lib/courier/sbin/courier start

while ! $ready ; do
    sleep 1
    pgrep courier > /dev/null
    if [ $? -eq 0 ]; then
        ready=true
    fi
done

echo '[start-courier] online'

# Wait for TERM signal
while ! $finished ; do
    pgrep courier > /dev/null
    if [ $? -ne 0 ]; then
        echo '[start-courier] courier unexpectedly quit'
        exit 2
    fi
    sleep 1
done

# Confirm it's exited, or die trying
sleep 1
pgrep courier > /dev/null
if [ $? -eq 0 ]; then
    echo '[start-courier] sending SIGKILL to courier'
    pkill -9 courier
    exit 3
fi
