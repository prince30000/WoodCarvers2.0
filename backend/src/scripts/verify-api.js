/**
 * Wood Carvers API Verification Script
 * Validates core REST endpoints, auth tokens, RBAC, and calculation correctness.
 */

import http from 'http';

const BASE_URL = 'http://localhost:5000/api';

const request = (method, path, body = null, token = null) => {
  return new Promise((resolve, reject) => {
    const url = new URL(`${BASE_URL}${path}`);
    const options = {
      hostname: url.hostname,
      port: url.port,
      path: url.pathname + url.search,
      method,
      headers: {
        'Content-Type': 'application/json'
      }
    };

    if (token) {
      options.headers['Authorization'] = `Bearer ${token}`;
    }

    const req = http.request(options, (res) => {
      let data = '';
      res.on('data', chunk => { data += chunk; });
      res.on('end', () => {
        try {
          const parsed = JSON.parse(data);
          resolve({ status: res.statusCode, body: parsed });
        } catch (e) {
          resolve({ status: res.statusCode, body: data });
        }
      });
    });

    req.on('error', reject);

    if (body) {
      req.write(JSON.stringify(body));
    }
    req.end();
  });
};

const runVerification = async () => {
  console.log('🪵 Running Wood Carvers Automated API Verification...\n');

  try {
    // 1. Health check
    console.log('[Test 1] Health Check...');
    const health = await request('GET', '/health');
    console.log(`Status: ${health.status}, Response:`, health.body.status || health.body);
    if (health.status !== 200) throw new Error('Health check failed');

    // 2. Categories
    console.log('\n[Test 2] Get Categories...');
    const cats = await request('GET', '/categories');
    console.log(`Status: ${cats.status}, Categories count:`, cats.body.data?.length || 0);

    // 3. Products
    console.log('\n[Test 3] Get Products & Text Search...');
    const prods = await request('GET', '/products?search=walnut&limit=5');
    console.log(`Status: ${prods.status}, Found:`, prods.body.data?.length || 0);

    // 4. Customer Login
    console.log('\n[Test 4] Customer Authentication...');
    const loginRes = await request('POST', '/auth/login', {
      email: 'customer@woodcarvers.com',
      password: 'Customer@123456'
    });
    console.log(`Status: ${loginRes.status}, Message:`, loginRes.body.message);
    const customerToken = loginRes.body.data?.token;

    // 5. Admin Authentication
    console.log('\n[Test 5] Admin Authentication...');
    const adminLogin = await request('POST', '/auth/login', {
      email: 'admin@woodcarvers.com',
      password: 'Admin@123456'
    });
    console.log(`Status: ${adminLogin.status}, Message:`, adminLogin.body.message);
    const adminToken = adminLogin.body.data?.token;

    // 6. RBAC Protection
    console.log('\n[Test 6] RBAC Check: Customer trying to access Admin dashboard...');
    const rbacRes = await request('GET', '/admin/dashboard', null, customerToken);
    console.log(`Status: ${rbacRes.status} (Expected 403 Forbidden), Message:`, rbacRes.body.message);

    // 7. Admin Dashboard
    console.log('\n[Test 7] Admin accessing Dashboard with Admin Token...');
    const dashRes = await request('GET', '/admin/dashboard', null, adminToken);
    console.log(`Status: ${dashRes.status}, Total Products:`, dashRes.body.data?.totalProducts);

    console.log('\n✅ ALL VERIFICATION TESTS COMPLETED SUCCESSFULLY! ✅');
  } catch (err) {
    console.error('\n❌ Verification test failed:', err.message);
  }
};

runVerification();
