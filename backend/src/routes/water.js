const express = require('express');
const router = express.Router();
const {
  addWaterEntry,
  getWaterEntries,
  getTodayWater,
  deleteWaterEntry,
} = require('../controllers/waterController');
const authMiddleware = require('../middleware/auth');

router.use(authMiddleware);

router.post('/', addWaterEntry);
router.get('/', getWaterEntries);
router.get('/today', getTodayWater);
router.delete('/:id', deleteWaterEntry);

module.exports = router;
