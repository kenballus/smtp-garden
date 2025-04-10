#!/bin/bash
perl -pe 's/<\d{1,3}/\n/g' courier.log
echo
