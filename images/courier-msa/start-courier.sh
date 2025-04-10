#!/bin/bash
# By Malcolm Schongalla - SMTP Garden Apache Courier-MTA, MSA version
# Version 1.0.1 - log formatting
# Version 1.0   - original (based on 'courier' start script v1.1)

authdaemond_cmd="/usr/local/sbin/authdaemond"
esmtpd_cmd="/usr/lib/courier/sbin/esmtpd-msa"
courier_cmd="/usr/lib/courier/sbin/courier"
self="[start-courier-msa]"

# Signal handling
stop_courier()
{
    echo "$self TERM or INT received..."
    $courier_cmd stop &
    $esmtpd_cmd stop &
    $authdaemond_cmd stop &
    finished=true
}

# Permission reset at shutdown
fix_permissions()
{
    # Tucked in here, because courier does not output newlines to the log:
    perl -pe 's/<\d{1,3}>/\n/g' /home/courier.log > /home/courier.txt

    if $has_UID && $has_GID; then
        echo -e "\n$self reassigning home folder ownership..."
        chown -R "$HOST_UID":"$HOST_GID" /home
    else
        echo -e "\n$self WARNING: No UID:GID provided, manually fix folder ownership!"
    fi
}


##############
# Script start
##############

trap 'stop_courier' SIGTERM SIGINT

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
rm -f /home/user1/WHOAMI /home/user1/ID /home/user1/ENV
rm -f /home/user2/WHOAMI /home/user2/ID /home/user2/ENV

echo "$self starting daemons..."

# Set up logs. Not using syslog, so must capture log output another way:
touch /home/courier.log
chmod 666 /home/courier.log
socat -u UNIX-RECV:/dev/log STDOUT | tee /home/courier.log &

# Go
$courier_cmd start & 2>&1
$authdaemond_cmd start & 2>&1
$esmtpd_cmd start & 2>&1

# Ensure everything started
ready_authdaemon=false
ready_esmtp=false
ready_courierd=false
while ! $ready_authdaemon -o ! $ready_esmtp -o ! $ready_courierd; do
    sleep 1

    pgrep authdaemond > /dev/null
    if [ $? -eq 0 ]; then
        ready_authdaemon=true
    fi

    pgrep couriertcpd > /dev/null
    if [ $? -eq 0 ]; then
        ready_esmtp=true
    fi

    pgrep courierd > /dev/null
    if [ $? -eq 0 ]; then
        ready_courierd=true
    fi
done

# Subsequent newline characters in echo help differentiate from courierlogger chaff
echo -e "\n$self online."

# Wait for TERM signal
finished=false
while ! $finished ; do
    pgrep couriertcpd > /dev/null
    esmtp_running=$?
    pgrep authdaemond > /dev/null
    authdaemond_running=$?
    pgrep courierd > /dev/null
    courierd_running=$?

    # if processes unexpectedly quit
    if [ $courierd_running -ne 0 ]; then
        echo -e "\n$self courierd unexpectedly quit"
        echo "$self - stopping esmtpd-msa and authdaemond, aborting"
        $authdaemond_cmd stop
        $esmtpd_cmd stop
        fix_permissions
        exit 2
    fi

    if [ $esmtp_running -ne 0 ]; then
        echo -e "\n$self esmtp unexpectedly quit"
        echo "$self - stopping courierd and authdaemond, aborting"
        $courier_cmd stop
        $authdaemond_cmd stop
        fix_permissions
        exit 2
    fi

    if [ $authdaemond_running -ne 0 ]; then
        echo -e "\n$self authdaemond unexpectedly quit"
        echo "$self - stopping courierd and esmtpd-msa, aborting"
        $courier_cmd stop
        $esmtpd_cmd stop
        fix_permissions
        exit 2
    fi

    sleep 1
done

sleep 1

# Confirm it's exited, or force it
# (exit codes are not really needed in docker deployment,
# but are included here for versatility)

exitcode=0
pgrep authdaemond > /dev/null
if [ $? -eq 0 ]; then
    echo -e "$self sending SIGKILL to authdaemond"
    pkill -9 authdaemond
    exitcode=4
fi

pgrep couriertcpd > /dev/null
if [ $? -eq 0 ]; then
    echo "$self sending SIGKILL to couriertcpd (esmtp)"
    pkill -9 couriertcpd
    exitcode=$(expr $exitcode + 8)
fi

pgrep courierd > /dev/null
if [ $? -eq 0 ]; then
    echo "$self sending SIGKILL to courierd"
    pkill -9 courierd
    exitcode=$(expr $exitcode + 16)
fi

echo "--$(date) END COURIER LOG--" | tee -a /home/courier.log

fix_permissions

exit $exitcode
