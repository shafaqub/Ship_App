const express = require('express');
const crypto = require('crypto');
const nodemailer = require('nodemailer');
const router = express.Router();
const User = require('../models/User');

function generateVerificationCode() {
  return crypto.randomInt(100000, 1000000).toString();
}

function hashVerificationCode(code) {
  return crypto.createHash('sha256').update(code).digest('hex');
}

function createMailer() {
  const smtpHost = process.env.SMTP_HOST?.trim();
  const smtpPort = process.env.SMTP_PORT?.trim();
  const smtpUser = process.env.SMTP_USER?.trim();
  const smtpPassword = process.env.SMTP_PASSWORD?.replace(/\s/g, '');
  if (!smtpHost || !smtpPort || !smtpUser || !smtpPassword) {
    return null;
  }

  return nodemailer.createTransport({
    host: smtpHost,
    port: Number(smtpPort),
    secure: process.env.SMTP_SECURE === 'true',
    auth: { user: smtpUser, pass: smtpPassword },
  });
}

async function sendVerificationEmail(email, code) {
  const transporter = createMailer();
  if (!transporter) {
    throw new Error('SMTP configuration is incomplete');
  }

  await transporter.sendMail({
    from: process.env.SMTP_FROM?.trim() || process.env.SMTP_USER?.trim(),
    to: email,
    subject: 'Your InterviewMe verification code',
    text: `Your InterviewMe verification code is ${code}. It expires in 15 minutes.`,
  });
}

// POST /api/auth/register
router.post('/register', async (req, res) => {
  try {
    const { name, email, password } = req.body;

    if (
      typeof name !== 'string' ||
      typeof email !== 'string' ||
      typeof password !== 'string' ||
      !name.trim() ||
      !email.trim() ||
      !password.trim()
    ) {
      return res.status(400).json({
        success: false,
        message: 'Name, email, and password are required',
      });
    }

    const normalizedEmail = email.trim().toLowerCase();
    if (!/^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(normalizedEmail)) {
      return res.status(400).json({ success: false, message: 'Please enter a valid email address' });
    }

    if (password.length < 6) {
      return res.status(400).json({
        success: false,
        message: 'Password must be at least 6 characters',
      });
    }

    let user = await User.findOne({ email: normalizedEmail });

    if (user && user.isVerified) {
      return res.status(400).json({
        success: false,
        message: 'An account with this email already exists',
      });
    }

    const code = generateVerificationCode();
    const expires = new Date(Date.now() + 15 * 60 * 1000); // 15 mins

    if (user && !user.isVerified) {
      user.name = name.trim();
      user.password = password;
      user.verificationCode = undefined;
      user.verificationCodeHash = hashVerificationCode(code);
      user.verificationCodeExpires = expires;
      await user.save();
    } else {
      user = new User({
        name: name.trim(),
        email: normalizedEmail,
        password,
        isVerified: false,
        verificationCodeHash: hashVerificationCode(code),
        verificationCodeExpires: expires,
      });
      await user.save();
    }

    try {
      await sendVerificationEmail(normalizedEmail, code);
    } catch (emailError) {
      console.error('Verification email error:', emailError.message);
      return res.status(503).json({
        success: false,
        message: 'We could not send the verification email. Please try again later.',
      });
    }

    return res.status(201).json({
      success: true,
      message: 'Verification code sent to your email address.',
      email: normalizedEmail,
    });
  } catch (error) {
    console.error('Registration error:', error);
    return res.status(500).json({
      success: false,
      message: 'Server error during registration',
    });
  }
});

// POST /api/auth/verify-email
router.post('/verify-email', async (req, res) => {
  try {
    const { email, code } = req.body;

    if (typeof email !== 'string' || typeof code !== 'string' || !email.trim() || !code.trim()) {
      return res.status(400).json({
        success: false,
        message: 'Email and verification code are required',
      });
    }

    const normalizedEmail = email.trim().toLowerCase();
    const user = await User.findOne({ email: normalizedEmail });

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User account not found',
      });
    }

    if (!user.verificationCodeHash || !user.verificationCodeExpires || user.verificationCodeExpires < new Date()) {
      return res.status(400).json({
        success: false,
        message: 'This verification code has expired. Please request a new code.',
      });
    }

    const providedHash = hashVerificationCode(code.trim());
    if (user.verificationCodeHash !== providedHash) {
      return res.status(400).json({
        success: false,
        message: 'Invalid verification code. Please check and try again.',
      });
    }

    user.isVerified = true;
    user.verificationCode = undefined;
    user.verificationCodeHash = undefined;
    user.verificationCodeExpires = undefined;
    await user.save();

    return res.status(200).json({
      success: true,
      message: 'Email verified successfully! Welcome to InterviewMe.',
      user: {
        id: user._id,
        email: user.email,
        name: user.name,
      },
    });
  } catch (error) {
    console.error('Verification error:', error);
    return res.status(500).json({
      success: false,
      message: 'Server error during verification',
    });
  }
});

// POST /api/auth/login
router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    if (typeof email !== 'string' || typeof password !== 'string' || !email.trim() || !password.trim()) {
      return res.status(400).json({
        success: false,
        message: 'Email and password are required',
      });
    }

    const normalizedEmail = email.trim().toLowerCase();
    const user = await User.findOne({ email: normalizedEmail });

    if (!user) {
      return res.status(401).json({
        success: false,
        message: 'Invalid email or password',
      });
    }

    const isMatch = await user.comparePassword(password);
    if (!isMatch) {
      return res.status(401).json({
        success: false,
        message: 'Invalid email or password',
      });
    }

    if (!user.isVerified) {
      return res.status(403).json({
        success: false,
        message: 'Please verify your email before signing in.',
      });
    }

    return res.status(200).json({
      success: true,
      message: 'Login successful',
      user: {
        id: user._id,
        email: user.email,
        name: user.name,
      },
    });
  } catch (error) {
    console.error('Login error:', error);
    return res.status(500).json({
      success: false,
      message: 'Server error during login',
    });
  }
});

module.exports = router;
