#!/bin/bash

# URL of the weather API endpoint
API_URL="<weather-api-url>"

# Interval between requests in seconds
INTERVAL=2

# Function to hit the API and log the response time
hit_api() {
  while true; do
    # Get start time in nanoseconds
    START_TIME=$(gdate +%s%N)

    # Make the request and get the response body and code
    RESPONSE=$(curl -s -w "\n%{http_code}" $API_URL)
    RESPONSE_BODY=$(echo "$RESPONSE" | sed '$d')
    RESPONSE_CODE=$(echo "$RESPONSE" | tail -n 1)

    # Get end time in nanoseconds
    END_TIME=$(gdate +%s%N)

    # Calculate response time in milliseconds
    RESPONSE_TIME=$(( (END_TIME - START_TIME) / 1000000 ))

    # Get current timestamp for logging
    TIMESTAMP=$(gdate '+%Y-%m-%d %H:%M:%S')

    # Extract the summary of the first element from the response body
    FIRST_SUMMARY=$(echo "$RESPONSE_BODY" | jq -r '.[0].summary')

    # Determine the color based on response time
    if [ $RESPONSE_TIME -gt 500 ]; then
      COLOR="\033[0;31m"  # Red
    else
      COLOR="\033[0;32m"  # Green
    fi

    # Reset color
    RESET="\033[0m"

    # Log the response code, response time, timestamp, and first summary
    echo -e "${COLOR}[$TIMESTAMP] Response Code: $RESPONSE_CODE, Response Time: ${RESPONSE_TIME}ms, First Summary: $FIRST_SUMMARY${RESET}"

    # Wait for the specified interval
    sleep $INTERVAL
  done
}

# Start hitting the API
hit_api