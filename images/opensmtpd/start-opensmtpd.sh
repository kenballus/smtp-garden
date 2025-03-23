#!/bin/bash
# By Malcolm Schongalla - SMTP Garden Apache OpenSMTPD 
# Version 1

smtpd_cmd="/usr/local/sbin/smtpd"
self="[start-opensmtpd]"

# Signal handling
stop_smtpd()
{
    echo "$self TERM or INT received.  smtpd status:"

# Commented out until setgid issue fixed
#    smtpctl pause smtp
#    smtpctl show queue
    finished=true
}

trap 'stop_smtpd' SIGTERM SIGINT

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

echo "$self starting daemon..."

$smtpd_cmd -T all

ready_smtpd=false
while ! $ready_smtpd; do
    sleep 1

    pgrep smtpd > /dev/null
    if [ $? -eq 0 ]; then
        ready_smtpd=true
    fi
done

echo "$self online."

# Wait for TERM signal
finished=false
while ! $finished ; do
    smtpd_pid=$(ps -C smtpd -o pid= | head -n 1)
    smtpd_running=$?
    
    if [ $smtpd_running -ne 0 ]; then
        echo "$self daemon unexpectedly quit"
        exit 2
    fi

    sleep 1
done

#sleep 1

exitcode=0

# No need to do this
#smtpd_pid=$(ps -C smtpd -o pid= | head -n 1)
#if [ $? -eq 0 ]; then
#    if [ ${smtpd_pid+x} ]; then
#        echo "$self sending SIGKILL to smtpd"
#        kill $smtpd_pid > /dev/null
#        exitcode=4
#    else
#        echo "$self Bad shutdown, PID unknown"
#        exitcode=8
#    fi
#fi

if $has_UID && $has_GID; then
    echo "$self reassigning home folder ownership..."
    chown -R "$HOST_UID":"$HOST_GID" /home
fi

exit $exitcode
