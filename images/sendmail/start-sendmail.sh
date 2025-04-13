#!/bin/bash
# By Malcolm Schongalla - SMTP Garden
# Version 2 - 2025-04-06, local user awareness and volume permissions
# Version 1 - original

sendmail_cmd="sendmail"
self="[start-sendmail]"

# Signal handling
stop_sendmail()
{
    echo "$self TERM or INT received..."
    pkill -15 sendmail
    finished=true
}

trap 'stop_sendmail' TERM INT

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
echo "$self preparing /var/spool tree..."
chown -R root:root /var/spool
chown smmsp:smmsp /var/spool/clientmqueue
chmod -R 770 /var/spool/clientmqueue

# Prevents a long delay starting sendmail while it figures out who it is
echo "127.0.0.1 `hostname` `hostname`.localdomain" >> /etc/hosts

# Start sendmail
echo "$self starting..."

# Commented out to see if it plays better with Dovecot Submission Server
#$sendmail_cmd -v -bd -d0,9 

$sendmail_cmd -bd
sendmail_status=$?

if [ $sendmail_status -ne 0 ]; then
    echo "$self failed to start"
    exit 1
fi
echo "$self now online"


# Wait for signal
finished=false
while ! $finished; do
    pgrep sendmail > /dev/null
    if [ $? -ne 0 ]; then
        echo "$self unexpectedly quit"
        exit 2
    fi
    sleep 1
done


# Confirm it's exited, or die trying
sleep 1
exitcode=0
pgrep sendmail
if [ $? -eq 0 ]; then
    echo "$self sending SIGKILL"
    pkill -9 sendmail
    exitcode=4
else
    echo "$self terminated"
fi

if $has_UID && $has_GID; then
    echo "$self reassigning home folder ownership..."
    chown -R "$HOST_UID":"$HOST_GID" /var/spool
fi

exit $exitcode
