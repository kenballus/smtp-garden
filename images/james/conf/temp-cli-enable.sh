#!/bin/bash
#Helper script for image development, gets james-cli.sh prepared
#Helpful for troubleshooting

ln /app/james-project/server/apps/spring-app/target/appassembler/bin/james-cli.sh /app/james/conf/james-cli.sh
chmod +x /app/james-project/server/apps/spring-app/target/appassembler/bin/james-cli.sh
chmod +x /app/james/conf/james-cli.sh
cat /app/james/conf/jmxremote.password
