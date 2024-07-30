#!/bin/bash
# By Malcolm Schongalla - SMTP Garden
# Version 1


finished=false

# Signal handling
stop_sendmail()
{
    echo '[sendmail] TERM or INT received...'
    pkill -15 sendmail
    finished=true
}

trap 'stop_sendmail' TERM INT


# Prevents a long delay starting sendmail while it figures out who it is
echo "127.0.0.1 `hostname` `hostname`.localdomain" >> /etc/hosts

# Start sendmail
echo '[sendmail] starting...'
sendmail -v -bd -d0,9 
sendmail_status=$?

if [ $sendmail_status -ne 0 ]; then
    echo '[sendmail] failed to start'
    exit 1
fi
echo '[sendmail] now online'


# Wait for signal
while ! $finished; do
    pgrep sendmail > /dev/null
    if [ $? -ne 0 ]; then
        echo '[sendmail] unexpectedly quit'
        exit 2
    fi
    sleep 1
done


# Confirm it's exited, or die trying
sleep 1
pgrep sendmail
if [ $? -eq 0 ]; then
    echo '[sendmail] sending SIGKILL'
    pkill -9 sendmail
    exit 3
else
    echo '[sendmail] terminated'
fi

