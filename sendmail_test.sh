#!/bin/bash

set -e

user=test
from_name='Test'
from_email=$1
to_name='Your name'
to_email=$2
file=/tmp/emailtest.eml

if [ -z "$from_email" ] || [ -z "$to_email" ]; then
    echo "Usage: $(basename $0) <email_from> <email_to>"
    exit 1
fi

echo -n "Preparing email ... "
cat > $file << EOL
Subject: Email test for $HOST.$DOMAIN
From: $from_name <$from_email>
To: $to_name <$to_email>
Content-Type: text/plain; charset=UTF-8

This is a test email for server $HOST.$DOMAIN.
You do not have to do anything, but remove it.
Thanks

EOL
echo "OK"

echo -n "Sending email using sendmail ... "
sendmail -f "$from_email" "$to_email" < $file
error=$?; if [ $error -ne 0 ]; then echo "ERROR: $error"; exit $error; fi
echo "OK"

echo -n "Waiting some seconds ... "
sleep 5
echo "OK"

echo "-----------------------------------------------------"
echo " Log"
echo "-----------------------------------------------------"
tail /var/log/socklog/mail/current

echo "-----------------------------------------------------"
echo " Outgoing email queue"
echo "-----------------------------------------------------"
postqueue -p
