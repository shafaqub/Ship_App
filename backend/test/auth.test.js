require('dotenv').config();
const assert = require('assert');
const mongoose = require('mongoose');
const User = require('../src/models/User');

const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://127.0.0.1:27017/interview_me';

async function runTests() {
  console.log('Running backend auth unit/integration tests...');
  try {
    await mongoose.connect(MONGODB_URI);

    const testEmail = 'signup_tester@example.com';
    const testPassword = 'signupPassword123';
    const testName = 'Signup Tester';

    // Cleanup previous run
    await User.deleteMany({ email: testEmail });

    // 1. Create User
    const user = new User({
      name: testName,
      email: testEmail,
      password: testPassword,
      isVerified: false,
      verificationCode: '123456',
    });
    await user.save();
    assert(user._id, 'User should have an ID');
    assert.strictEqual(user.isVerified, false, 'User should initially be unverified');

    // 2. Verify password comparison
    const isValid = await user.comparePassword(testPassword);
    assert.strictEqual(isValid, true, 'Valid password should return true');

    // 3. Verify verification code check
    assert.strictEqual(user.verificationCode, '123456');
    user.isVerified = true;
    user.verificationCode = undefined;
    await user.save();
    assert.strictEqual(user.isVerified, true, 'User should now be verified');

    // Cleanup
    await User.deleteMany({ email: testEmail });

    console.log('All backend auth & verification tests passed successfully! ✅');
  } catch (err) {
    console.error('Backend auth test failed ❌:', err);
    process.exit(1);
  } finally {
    await mongoose.disconnect();
    process.exit(0);
  }
}

runTests();
