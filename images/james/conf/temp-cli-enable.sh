#!/bin/bash
# Helper script for image development
# Prints the expected location of james-cli.sh as a friendly reminder
# Also prints the required username and password to use with the script

chmod +x /app/james-project/server/apps/spring-app/target/appassembler/bin/james-cli.sh
echo "/app/james-project/server/apps/spring-app/target/appassembler/bin/james-cli.sh"
cat /app/james/conf/jmxremote.password
