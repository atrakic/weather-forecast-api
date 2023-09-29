#!/bin/bash
set -e

host="weather-forecast-api.local"
url="localhost:80"

limit=${1:-5}
n=0
while [[ "$n" -lt "$limit" ]];
do
   n=$((n+1))
   echo "$n: $(curl -fiskX GET $url -H"Host: ${host}")"
   echo
   curl -fisk GET "$url/WeatherForecast" -H"Host: ${host}" | xargs
   sleep 1
done
