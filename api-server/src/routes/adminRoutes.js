const express = require('express');
const router = express.Router();
const authMiddleware = require('../middleware/auth');
const { markDelivered } = require('../controllers/admin');

router.post('/orders/:orderId/deliver', authMiddleware, markDelivered);

module.exports = router;
