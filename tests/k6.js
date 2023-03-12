// brew install k6
import http from 'k6/http';
import { sleep } from 'k6';

export const options = {
  insecureSkipTLSVerify: true,
  thresholds: {
    http_req_failed: ['rate<0.01'], // http errors should be less than 1%
    http_req_duration: ['p(95)<500'], // 95 percent of response times must be below 500ms
  },
};

export default function () {
  const req1 = {
    params: {
      headers: {'Host': 'weather-forecast-api.local'},
    },
    method: 'GET',
    url: 'http://localhost/WeatherForecast',
  };
  const responses = http.batch([req1]);
}
