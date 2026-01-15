const express = require('express');
const router = express.Router();
const {
  addSteps,
  getTodaySteps,
  getStepsHistory,
} = require('../controllers/stepsController');
const authMiddleware = require('../middleware/auth');

router.use(authMiddleware);

router.post('/', addSteps);
router.get('/today', getTodaySteps);
router.get('/', getStepsHistory);

module.exports = router;
