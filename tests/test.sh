#!/bin/bash
set -e

host="weather-forecast-api.local"
url="localhost:80"

counter=0
while true; do
   counter=$((counter+1))
   echo "$counter: $(curl -fiskX GET $url -H"Host: ${host}")"
   echo
   curl -fisk GET "$url/WeatherForecast" -H"Host: ${host}" | xargs # | jq ". | length"
   #curl -fisk GET "$url/metrics" -H"Host: ${host}"
   sleep 1
done
