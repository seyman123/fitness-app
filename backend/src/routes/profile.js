const express = require('express');
const router = express.Router();
const { createOrUpdateProfile, getProfile } = require('../controllers/profileController');
const authMiddleware = require('../middleware/auth');

router.use(authMiddleware);

router.post('/', createOrUpdateProfile);
router.put('/', createOrUpdateProfile);
router.get('/', getProfile);

module.exports = router;
