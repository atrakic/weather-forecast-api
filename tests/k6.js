// brew install k6
import http from 'ks/http';
import { sleep } from 'k6';

export const options = {
    duration: '1m',
    vus: 50,
    hosts: {
      'weather-forecast-api.local:80': '127.0.0.1:80',
      'weather-forecast-api.local:443': '127.0.0.1:443',
    },
    thresholds: {
      http_req_failed: ['rate<0.01'], // http errors should be less than 1%
      http_req_duration: ['p(95)<500'], // 95 percent of response times must be below 500ms
    },
  };

export default function () {
  // docs of k6 say this is how to adds host header
  // needed as ingress is created with this host value
  const params = {
    headers: {'host': 'weather-forecast-api.local'},
  };

  const req1 = {
  	method: 'GET',
  	url: 'http://weather-forecast-api.local/WeatherForecast',
  };

  for(let i=0; i<20; i++){
    const res = http.batch([req1], params);
    sleep(1);
  }
}
