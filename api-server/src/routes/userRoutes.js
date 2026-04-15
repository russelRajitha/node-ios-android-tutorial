const express = require('express');
const router = express.Router();
const authMiddleware = require('../middleware/auth');
const { profile } = require('../controllers/user');

router.get('/profile', authMiddleware, profile);

module.exports = router;