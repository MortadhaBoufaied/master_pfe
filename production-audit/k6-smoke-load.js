import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  thresholds: {
    http_req_failed: ['rate<0.02'],
    http_req_duration: ['p(95)<750', 'p(99)<1500'],
  },
  scenarios: {
    smoke: {
      executor: 'constant-vus',
      vus: Number(__ENV.K6_VUS || 5),
      duration: __ENV.K6_DURATION || '1m',
    },
  },
};

const baseUrl = __ENV.BASE_URL || 'http://localhost:8091';
const token = __ENV.JWT_TOKEN || '';

const endpoints = [
  '/actuator/health',
  '/api/mobile/test',
  '/api/academy',
  '/api/dashboard/admin',
];

export default function () {
  const headers = token ? { Authorization: `Bearer ${token}` } : {};

  for (const endpoint of endpoints) {
    const response = http.get(`${baseUrl}${endpoint}`, { headers });
    check(response, {
      [`${endpoint} returned bounded status`]: (r) => [200, 401, 403, 404].includes(r.status),
      [`${endpoint} responded under 1500ms`]: (r) => r.timings.duration < 1500,
    });
  }

  sleep(1);
}

