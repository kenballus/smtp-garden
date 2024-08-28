#!/bin/bash
# By Malcolm Schongalla - SMTP Garden msmtp
# Version 1

# Why this script? Because containerized msmtp does not always gracefully
# exit on its own

if [ -z "$1" ]; then
    myport="25"
else
    myport=$1
fi

finished=false

# Signal handling
stop_msmtpd()
{
    echo '[msmtp] TERM or INT received...'
    pkill -15 msmtpd > /dev/null
    finished=true
}

trap 'stop_msmtpd' TERM INT

# Start msmtpd
echo '[msmtp] starting...'

msmtpd --log=/var/msmtpd.log --port=$myport &
if [ $? -ne 0 ]; then
    echo '[msmtp] msmtpd failed to start'
    exit 1
fi

echo '[msmtp] online'

# Wait for signal
while ! $finished; do
    pgrep msmtpd > /dev/null
    if [ $? -ne 0 ]; then
        echo '[msmtp] msmtdp unexpectedly quit'
        exit 2
    fi
    sleep 1
done

# Confirm it's exited, or die trying
sleep 1
pgrep msmtpd > /dev/null
if [ $? -eq 0 ]; then
    echo '[msmtp] sending SIGKILL to msmtpd'
    pkill -9 msmtpd
    exit 3
fi

