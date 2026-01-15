const express = require('express');
const router = express.Router();
const {
  addNutritionLog,
  getNutritionLogs,
  getTodayNutrition,
  deleteNutritionLog,
} = require('../controllers/nutritionController');
const authMiddleware = require('../middleware/auth');

router.use(authMiddleware);

router.post('/', addNutritionLog);
router.get('/', getNutritionLogs);
router.get('/today', getTodayNutrition);
router.delete('/:id', deleteNutritionLog);

module.exports = router;
