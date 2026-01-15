const express = require('express');
const router = express.Router();
const statisticsController = require('../controllers/statisticsController');
const authMiddleware = require('../middleware/auth');

// Tüm route'lar authentication gerektirir
router.use(authMiddleware);

router.get('/overview', statisticsController.getOverviewStats);
router.get('/weekly-comparison', statisticsController.getWeeklyComparison);

module.exports = router;
