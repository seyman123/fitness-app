const express = require('express');
const router = express.Router();
const weightController = require('../controllers/weightController');
const authMiddleware = require('../middleware/auth');

// Tüm route'lar authentication gerektirir
router.use(authMiddleware);

// Kilo geçmişi CRUD
router.post('/', weightController.createWeightEntry);
router.get('/', weightController.getWeightHistory);
router.get('/stats', weightController.getWeightStats);
router.get('/:id', weightController.getWeightEntry);
router.put('/:id', weightController.updateWeightEntry);
router.delete('/:id', weightController.deleteWeightEntry);

module.exports = router;
