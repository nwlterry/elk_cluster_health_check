#!/bin/bash

##
# Cluster Health Check
##

SERVER=$(hostname)
SERVERFQDN=$(hostname -f)

echo -e "\e[1mServer : $SERVER\e[0m"
echo "Please enter user name:"
read username
domainusername="domain\\$username"
echo "User name is $domainusername"
echo -n "Please enter user password:"
read -s userpassword
echo

# URL to check
URL="https://$SERVERFQDN:9200/_cluster/health"

# Expected response value
EXPECTED_RESPONSE="green"

# Delay between attempts (in seconds)
DELAY=15

while true; do
  # Perform the curl request and store the result
  RESPONSE=$(curl -k -s -u "${domainusername}:${userpassword}" $URL)

  # Extract the specific value from the JSON response
  ACTUAL_RESPONSE=$(echo $RESPONSE | jq -r '.status')

  # Check if the actual response matches the expected response
  if [ "$ACTUAL_RESPONSE" == "$EXPECTED_RESPONSE" ]; then
    echo "Cluster Status is $ACTUAL_RESPONSE. Cluster is healthy."
    echo -e "\e[1mElasticearch service will be stopped and Server $SERVER will be restarted now...\e[0m"
    sleep $DELAY
    # Command to restart the server
    systemctl stop elasticsearch.service
    reboot
    exit 0
  else
    echo "Cluster still under recovery. Retrying in $DELAY seconds..."
    sleep $DELAY
  fi
done
