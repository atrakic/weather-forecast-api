#!/bin/bash
set -e

service="weather-forecast-api"
url="localhost:80"

counter=0
while true; do
   counter=$((counter+1))
   echo "$counter: $(curl -f -i -skX GET $url -H"Host: ${service}.local")"
   echo
   #curl -skX GET "$url/WeatherForecast" -H"Host: $service.local" | xargs # | jq ". | length"
   sleep 1
done
