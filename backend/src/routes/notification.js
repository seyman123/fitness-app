const express = require('express');
const router = express.Router();
const authMiddleware = require('../middleware/auth');
const {
  getNotificationSettings,
  updateNotificationSettings,
  resetNotificationSettings,
} = require('../controllers/notificationController');

// All notification routes require authentication
router.use(authMiddleware);

// GET /api/notifications - Get notification settings
router.get('/', getNotificationSettings);

// PUT /api/notifications - Update notification settings
router.put('/', updateNotificationSettings);

// POST /api/notifications/reset - Reset to default settings
router.post('/reset', resetNotificationSettings);

module.exports = router;
