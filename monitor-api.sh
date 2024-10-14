#!/bin/bash

# URL of your API endpoint
API_URL="<api-url>"

# Interval between requests in seconds
INTERVAL=2

# Function to hit the API and log the response time
hit_api() {
  while true; do
    # Get start time in nanoseconds
    START_TIME=$(gdate +%s%N)

    # Make the request and get the response code
    RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" $API_URL)

    # Get end time in nanoseconds
    END_TIME=$(gdate +%s%N)

    # Calculate response time in milliseconds
    RESPONSE_TIME=$(( (END_TIME - START_TIME) / 1000000 ))

    # Get current timestamp for logging
    TIMESTAMP=$(gdate '+%Y-%m-%d %H:%M:%S')

    # Log the response code, response time, and timestamp
    echo "[$TIMESTAMP] Response Code: $RESPONSE, Response Time: ${RESPONSE_TIME}ms"

    # Wait for the specified interval
    sleep $INTERVAL
  done
}

# Start hitting the API
hit_api
