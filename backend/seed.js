require('dotenv').config();
const mongoose = require('mongoose');
const User = require('./src/models/User');

const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://127.0.0.1:27017/interview_me';

const SEED_USER = {
  email: 'alex@example.com',
  password: 'password123',
  name: 'Alex',
  isVerified: true,
};

async function seed() {
  try {
    await mongoose.connect(MONGODB_URI);
    console.log('Connected to MongoDB for seeding...');

    let user = await User.findOne({ email: SEED_USER.email });
    if (user) {
      console.log(`Seed user (${SEED_USER.email}) already exists. Updating password & verification status...`);
      user.password = SEED_USER.password;
      user.name = SEED_USER.name;
      user.isVerified = true;
      await user.save();
      console.log(`Seed user (${SEED_USER.email}) updated successfully.`);
    } else {
      user = new User(SEED_USER);
      await user.save();
      console.log(`Seed user (${SEED_USER.email}) created successfully.`);
    }

    console.log('\nDevelopment Login Credentials:');
    console.log(`  Email:    ${SEED_USER.email}`);
    console.log(`  Password: ${SEED_USER.password}`);
  } catch (err) {
    console.error('Error seeding database:', err);
    process.exit(1);
  } finally {
    await mongoose.disconnect();
    console.log('MongoDB connection closed.');
  }
}

seed();
