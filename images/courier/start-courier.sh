#!/bin/bash
# By Malcolm Schongalla - SMTP Garden Apache Courier-MTA
# Version 1

authdaemond_cmd="/usr/local/sbin/authdaemond"
esmtpd_cmd="/usr/lib/courier/share/esmtpd"
self="[start-courier]"

finished=false
ready_authdaemon=false
ready_esmtp=false

# Signal handling
stop_courier()
{
    echo "$self TERM or INT received..."
    $esmtpd_cmd stop
    $authdaemond_cmd stop
    finished=true
}

trap 'stop_courier' TERM INT

echo "$self starting..."
#cd /usr/lib/courier/share

$authdaemond_cmd start 2>&1
$esmtpd_cmd start 2>&1

while ! $ready_authdaemon -a ! $ready_esmtp; do
    sleep 1

    pgrep authdaemond > /dev/null
    if [ $? -eq 0 ]; then
        ready_authdaemon=true
    fi

    pgrep courier > /dev/null
    if [ $? -eq 0 ]; then
        ready_esmtp=true
    fi
done

echo "$self authdaemond and esmtp online"

# Wait for TERM signal
while ! $finished ; do
    pgrep courier > /dev/null
    esmtp_running=$?
    pgrep authdaemond > /dev/null
    authdaemond_running=$?

    # if both processed quit
    if [ $esmtp_running -ne 0 -a $authdaemond_running -ne 0 ]; then
        echo "$self esmtp and authdaemond unexpectedly quit"
        exit 6
    fi

    # if esmtp only quit
    if [ $esmtp_running -ne 0 ]; then
        echo "$self esmtp unexpectedly quit"
        echo "$self - stopping authdaemond"
        $authdaemond_cmd stop
        exit 2
    fi

    # if authdaemond quit
    if [ $authdaemond_running -ne 0 ]; then
        echo "$self authdaemond unexpectedly quit"
        echo "$self - stopping esmtpd"
        $esmtpd_cmd stop
        exit 4
    fi

    sleep 1
done

# Confirm it's exited, or die trying
sleep 1

exitcode=0

pgrep authdaemond > /dev/null
if [ $? -eq 0 ]; then
    echo "$self sending SIGKILL to authdaemond"
    pkill -9 authdaemond
    exitcode=4
fi

pgrep courier > /dev/null
if [ $? -eq 0 ]; then
    echo "$self sending SIGKILL to courier"
    pkill -9 courier
    exitcode=$(expr $exitcode + 8)
fi

echo $exitcode
