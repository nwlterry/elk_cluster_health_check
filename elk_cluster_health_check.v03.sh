#!/bin/bash
##
# Cluster Health Check with Robust Domain Account and Password Validation
##
SERVER=$(hostname)
SERVERFQDN=$(hostname -f)
echo -e "\e[1mServer: $SERVER\e[0m"

# Function to prompt for credentials
prompt_credentials() {
  echo "Please enter user name:"
  read username
  domainusername="domain\\$username"
  echo "User name is $domainusername"
  echo -n "Please enter user password:"
  read -s userpassword
  echo
}

# URL to check
URL="https://$SERVERFQDN:9200/_cluster/health"
# Expected response value
EXPECTED_RESPONSE="green"
# Delay between attempts (in seconds)
DELAY=15

while true; do
  # Prompt for credentials
  prompt_credentials

  # Attempt to validate credentials by making a test curl request and capturing HTTP status code
  HTTP_STATUS=$(curl -k -s -o /dev/null -w "%{http_code}" -u "${domainusername}:${userpassword}" $URL)
  if [ "$HTTP_STATUS" -eq 200 ]; then
    echo "Credentials validated successfully."
    while true; do
      # Perform the curl request and store the result
      RESPONSE=$(curl -k -s -u "${domainusername}:${userpassword}" $URL)
      # Check if curl request was successful
      if [ $? -eq 0 ]; then
        # Extract the specific value from the JSON response
        ACTUAL_RESPONSE=$(echo "$RESPONSE" | jq -r '.status' 2>/dev/null)
        # Check if jq parsed the response successfully
        if [ $? -eq 0 ] && [ -n "$ACTUAL_RESPONSE" ]; then
          # Check if the actual response matches the expected response
          if [ "$ACTUAL_RESPONSE" == "$EXPECTED_RESPONSE" ]; then
            echo "Cluster Status is $ACTUAL_RESPONSE. Cluster is healthy."
            echo -e "\e[1mElasticsearch service will be stopped and Server $SERVER will be restarted now...\e[0m"
            sleep $DELAY
            # Command to restart the server
            systemctl stop elasticsearch.service
            reboot
            exit 0
          else
            echo "Cluster still under recovery. Retrying in $DELAY seconds..."
            sleep $DELAY
          fi
        else
          echo "Failed to parse cluster health response. Please check cluster status or network."
          break # Break inner loop to re-prompt credentials
        fi
      else
        echo "Failed to connect to cluster. Please check network or server status."
        break # Break inner loop to re-prompt credentials
      fi
    done
  else
    echo -e "\e[31mInvalid username or password (HTTP Status: $HTTP_STATUS). Please try again.\e[0m"
    sleep 2
  fi
done
