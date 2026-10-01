const express = require('express');
const crypto = require('crypto');
const bcrypt = require('bcryptjs');
const nodemailer = require('nodemailer');

const { db } = require('../firebase');

const router = express.Router();

function normalizeEmail(email) {
  return String(email || '').trim().toLowerCase();
}

function hashCode(code) {
  return crypto
    .createHash('sha256')
    .update(code)
    .digest('hex');
}

function createVerificationCode() {
  return String(Math.floor(100000 + Math.random() * 900000));
}

function userData(doc) {
  const data = doc.data();

  return {
    id: doc.id,
    name: data.name,
    email: data.email,
    isVerified: data.isVerified === true,
  };
}

async function sendVerificationEmail(email, name, code) {
  const host = process.env.SMTP_HOST;
  const port = Number(process.env.SMTP_PORT || 587);
  const user = process.env.SMTP_USER;
  const pass = process.env.SMTP_PASS;
  const from = process.env.SMTP_FROM || user;

  // Development fallback.
  // If SMTP is not configured, return the code to the frontend
  // so registration can still be tested locally.
  if (!host || !user || !pass) {
    console.log(`DEV verification code for ${email}: ${code}`);

    return {
      sent: false,
      devCode: code,
    };
  }

  const transporter = nodemailer.createTransport({
    host,
    port,
    secure: port === 465,
    auth: {
      user,
      pass,
    },
  });

  await transporter.sendMail({
    from,
    to: email,
    subject: 'InterviewMe Email Verification',
    text: `Hi ${name}, your InterviewMe verification code is ${code}. This code expires in 10 minutes.`,
  });

  return {
    sent: true,
    devCode: null,
  };
}

// REGISTER
router.post('/register', async (req, res) => {
  try {
    const name = String(req.body.name || '').trim();
    const email = normalizeEmail(req.body.email);
    const password = String(req.body.password || '');

    if (!name || !email || !password) {
      return res.status(400).json({
        success: false,
        message: 'Name, email and password are required.',
      });
    }

    if (password.length < 6) {
      return res.status(400).json({
        success: false,
        message: 'Password must be at least 6 characters.',
      });
    }

    const userRef = db.collection('users').doc(
      crypto.createHash('sha256').update(email).digest('hex')
    );

    const existing = await userRef.get();

    if (existing.exists) {
      const existingData = existing.data();

      if (existingData.isVerified) {
        return res.status(409).json({
          success: false,
          message: 'An account with this email already exists.',
        });
      }
    }

    const passwordHash = await bcrypt.hash(password, 12);
    const code = createVerificationCode();

    await userRef.set(
      {
        name,
        email,
        passwordHash,
        isVerified: false,
        verificationCodeHash: hashCode(code),
        verificationCodeExpires: Date.now() + 10 * 60 * 1000,
        createdAt: existing.exists
          ? existing.data().createdAt
          : new Date(),
        updatedAt: new Date(),
      },
      { merge: true }
    );

    const emailResult = await sendVerificationEmail(email, name, code);

    return res.status(201).json({
      success: true,
      message: emailResult.sent
        ? 'Verification code sent to your email.'
        : 'Registration successful. Verification code generated.',
      ...(emailResult.devCode
        ? { devCode: emailResult.devCode }
        : {}),
    });
  } catch (error) {
    console.error('Register error:', error);

    return res.status(500).json({
      success: false,
      message: 'Registration failed.',
    });
  }
});

// VERIFY EMAIL
router.post('/verify-email', async (req, res) => {
  try {
    const email = normalizeEmail(req.body.email);
    const code = String(req.body.code || '').trim();

    if (!email || !code) {
      return res.status(400).json({
        success: false,
        message: 'Email and verification code are required.',
      });
    }

    const userRef = db.collection('users').doc(
      crypto.createHash('sha256').update(email).digest('hex')
    );

    const userDoc = await userRef.get();

    if (!userDoc.exists) {
      return res.status(404).json({
        success: false,
        message: 'Account not found.',
      });
    }

    const data = userDoc.data();

    if (data.isVerified) {
      return res.status(400).json({
        success: false,
        message: 'Email is already verified.',
      });
    }

    if (
      !data.verificationCodeExpires ||
      Date.now() > data.verificationCodeExpires
    ) {
      return res.status(400).json({
        success: false,
        message: 'Verification code has expired.',
      });
    }

    if (hashCode(code) !== data.verificationCodeHash) {
      return res.status(400).json({
        success: false,
        message: 'Invalid verification code.',
      });
    }

    await userRef.update({
      isVerified: true,
      verificationCodeHash: null,
      verificationCodeExpires: null,
      updatedAt: new Date(),
    });

    const updatedDoc = await userRef.get();

    return res.status(200).json({
      success: true,
      message: 'Email verified successfully.',
      user: userData(updatedDoc),
    });
  } catch (error) {
    console.error('Verify email error:', error);

    return res.status(500).json({
      success: false,
      message: 'Email verification failed.',
    });
  }
});

// LOGIN
router.post('/login', async (req, res) => {
  try {
    const email = normalizeEmail(req.body.email);
    const password = String(req.body.password || '');

    if (!email || !password) {
      return res.status(400).json({
        success: false,
        message: 'Email and password are required.',
      });
    }

    const userRef = db.collection('users').doc(
      crypto.createHash('sha256').update(email).digest('hex')
    );

    const userDoc = await userRef.get();

    if (!userDoc.exists) {
      return res.status(401).json({
        success: false,
        message: 'Invalid email or password.',
      });
    }

    const data = userDoc.data();

    const passwordMatches = await bcrypt.compare(
      password,
      data.passwordHash
    );

    if (!passwordMatches) {
      return res.status(401).json({
        success: false,
        message: 'Invalid email or password.',
      });
    }

    if (!data.isVerified) {
      return res.status(403).json({
        success: false,
        message: 'Please verify your email before logging in.',
      });
    }

    return res.status(200).json({
      success: true,
      message: 'Login successful.',
      user: userData(userDoc),
    });
  } catch (error) {
    console.error('Login error:', error);

    return res.status(500).json({
      success: false,
      message: 'Login failed.',
    });
  }
});

module.exports = router;
