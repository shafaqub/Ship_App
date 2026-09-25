const express = require('express');
const cors = require('cors');
const authRoutes = require('./routes/auth');

const app = express();

app.use(cors());
app.use(express.json());

app.use('/api/auth', authRoutes);
app.use('/api', authRoutes); // Fallback for /api/login

app.get('/health', (req, res) => {
  res.json({ status: 'ok', service: 'ship-app-backend' });
});

module.exports = app;
