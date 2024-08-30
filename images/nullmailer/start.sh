#!/bin/bash
# By Malcolm Schongalla - SMTP Garden nullmailer
# Version 1.0.1

# Why this script? Because containerized nullmailer doesn't gracefully
# exit on its own


# Signal handling
stop_smtpd()
{
    echo '[nullmailer] TERM or INT received...'
    pkill -15 nullmailer-send > /dev/null
    pkill -15 nullmailer-smtpd > /dev/null
    pkill -15 nc > /dev/null
    finished=true
}

trap 'stop_smtpd' TERM INT


# Start nullmailer suite
if [ -z "$1" ]; then
    myport="25"
else
    myport=$1
fi

finished=false

echo '[nullmailer] starting...'

nullmailer-send &
if [ $? -ne 0 ]; then
    echo '[nullmailer] nullmailer-send failed to start'
    exit 1
fi

nc -lk -p $myport -c nullmailer-smtpd &
if [ $? -ne 0 ]; then
    echo '[nullmailer] ncat nullmailer-smtpd launcher failed to start'
    exit 2
fi

echo '[nullmailer] online'


# Wait for signal
while ! $finished; do
    pgrep nullmailer-send > /dev/null
    if [ $? -ne 0 ]; then
        echo '[nullmailer] nullmailer-send unexpectedly quit'
        pkill nc > /dev/null
        exit 3
    fi

    pgrep nc > /dev/null
    if [ $? -ne 0 ]; then
        echo '[nullmailer] ncat unexpectedly quit'
        pkill nullmailer-send > /dev/null
        exit 4
    fi

    sleep 1
done


# Confirm it's exited, or die trying
sleep 1
did_sigkill=false
pgrep nullmailer-send > /dev/null
if [ $? -eq 0 ]; then
    echo '[nullmailer] sending SIGKILL to nullmailer-send'
    pkill -9 nullmailer-send
    did_sigkill=true
fi

pgrep nc > /dev/null
if [ $? -eq 0 ]; then
    echo '[nullmailer] sending SIGKILL to nc'
    pkill -9 nc
    did_sigkill=true
fi

if did_sigkill; then
    exit 5
else
    exit 0
fi
