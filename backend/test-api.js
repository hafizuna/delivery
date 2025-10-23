// test-api.js - Simple API test script
const axios = require('axios');

const BASE_URL = 'http://localhost:3000/api/v1';

async function testAPI() {
  console.log('🧪 Testing Foodie Backend API\n');

  try {
    // 1. Health Check
    console.log('1. Testing Health Check...');
    const health = await axios.get('http://localhost:3000/health');
    console.log('✅ Health:', health.data);
    console.log('');

    // 2. Register a test customer
    console.log('2. Registering test customer...');
    const registerData = {
      phoneNumber: '1234567890',
      countryCode: '+1',
      password: 'password123',
      firstName: 'Test',
      lastName: 'Customer',
      role: 'customer',
      email: 'test@foodie.com'
    };

    const registerResponse = await axios.post(`${BASE_URL}/auth/register`, registerData);
    console.log('✅ Registration successful!');
    console.log('User ID:', registerResponse.data.user.id);
    console.log('Token:', registerResponse.data.token.substring(0, 50) + '...');
    console.log('');

    const token = registerResponse.data.token;
    const refreshToken = registerResponse.data.refreshToken;

    // 3. Login
    console.log('3. Testing login...');
    const loginData = {
      phoneNumber: '1234567890',
      countryCode: '+1',
      password: 'password123'
    };

    const loginResponse = await axios.post(`${BASE_URL}/auth/login`, loginData);
    console.log('✅ Login successful!');
    console.log('User:', loginResponse.data.user.firstName, loginResponse.data.user.lastName);
    console.log('Wallet Amount:', loginResponse.data.user.walletAmount);
    console.log('');

    // 4. Get Profile
    console.log('4. Getting user profile...');
    const profileResponse = await axios.get(`${BASE_URL}/users/profile`, {
      headers: { Authorization: `Bearer ${token}` }
    });
    console.log('✅ Profile retrieved!');
    console.log('Phone:', profileResponse.data.phoneNumber);
    console.log('Role:', profileResponse.data.role);
    console.log('Created:', profileResponse.data.createdAt);
    console.log('');

    // 5. Update Profile
    console.log('5. Updating profile...');
    const updateData = {
      firstName: 'Updated',
      lastName: 'Customer',
      email: 'updated@foodie.com'
    };

    const updateResponse = await axios.put(`${BASE_URL}/users/profile`, updateData, {
      headers: { Authorization: `Bearer ${token}` }
    });
    console.log('✅ Profile updated!');
    console.log('New name:', updateResponse.data.firstName, updateResponse.data.lastName);
    console.log('New email:', updateResponse.data.email);
    console.log('');

    // 6. Refresh Token
    console.log('6. Testing token refresh...');
    const refreshResponse = await axios.post(`${BASE_URL}/auth/refresh`, {
      refreshToken: refreshToken
    });
    console.log('✅ Token refreshed!');
    console.log('New token:', refreshResponse.data.token.substring(0, 50) + '...');
    console.log('');

    // 7. Logout
    console.log('7. Testing logout...');
    const logoutResponse = await axios.post(`${BASE_URL}/auth/logout`, {}, {
      headers: { Authorization: `Bearer ${token}` }
    });
    console.log('✅ Logged out!');
    console.log('');

    console.log('🎉 All tests passed successfully!');
    
  } catch (error) {
    if (error.response) {
      console.error('❌ Error:', error.response.data);
    } else {
      console.error('❌ Error:', error.message);
    }
  }
}

// Run tests
testAPI();
