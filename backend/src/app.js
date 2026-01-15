require('dotenv').config();
const express = require('express');
const cors = require('cors');

const authRoutes = require('./routes/auth');
const profileRoutes = require('./routes/profile');
const waterRoutes = require('./routes/water');
const nutritionRoutes = require('./routes/nutrition');
const workoutRoutes = require('./routes/workout');
const stepsRoutes = require('./routes/steps');
const weightRoutes = require('./routes/weight');
const statisticsRoutes = require('./routes/statistics');
const notificationRoutes = require('./routes/notification');

const app = express();

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.get('/health', (req, res) => {
  res.json({ status: 'ok', message: 'Fitness App API çalışıyor' });
});

app.use('/api/auth', authRoutes);
app.use('/api/profile', profileRoutes);
app.use('/api/water', waterRoutes);
app.use('/api/nutrition', nutritionRoutes);
app.use('/api/workouts', workoutRoutes);
app.use('/api/steps', stepsRoutes);
app.use('/api/weight', weightRoutes);
app.use('/api/statistics', statisticsRoutes);
app.use('/api/notifications', notificationRoutes);

app.use((req, res) => {
  res.status(404).json({ error: 'Endpoint bulunamadı' });
});

app.use((err, req, res, next) => {
  console.error('Error:', err);
  res.status(500).json({ error: 'Sunucu hatası' });
});

module.exports = app;
