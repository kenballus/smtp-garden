#!/bin/bash
# By Malcolm Schongalla - SMTP Garden aiosmtpd
# Version 1

aio_cmd="python3 server.py"
self="[start-aiosmtpd]"

# Signal handling
stop_aio()
{
    echo "$self TERM or INT received..."
    finished=true
}

trap 'stop_aio' SIGTERM SIGINT

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

echo "$self starting python script..."

$aio_cmd & 2>&1

ready_aio=false
while ! $ready_aio; do
    sleep 1

    pgrep python > /dev/null
    if [ $? -eq 0 ]; then
        ready_aio=true
    fi
done

echo "$self online."

# Wait for TERM signal
finished=false
while ! $finished ; do
    pgrep python > /dev/null
    aio_running=$?
    
    if [ $aio_running -ne 0 ]; then
        echo "$self python unexpectedly quit"
        exit 2
    fi

    sleep 1
done

pkill python > /dev/null

i=5
while [ $i -ge 1 ]; do
    sleep 1
    pgrep python > /dev/null
    if [ $? -eq 0 ]; then
        echo "$self waiting shutdown $i..."
    else
        i=1
    fi
    ((i--))
done

# Confirm it's exited, or force it.
# (exit codes are not really needed in docker deployment,
# but are included here for versatility)

exitcode=0
pgrep python > /dev/null
if [ $? -eq 0 ]; then
    echo "$self sending SIGKILL to python"
    pkill -9 python > /dev/null
    exitcode=4
fi

if $has_UID && $has_GID; then
    echo "$self reassigning home folder ownership..."
    chown -R "$HOST_UID":"$HOST_GID" /home
fi

exit $exitcode
