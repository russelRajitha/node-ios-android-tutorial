const express = require('express');
const router = express.Router();
const authMiddleware = require('../middleware/auth');
const { checkout, getOrders, getOrderDetail } = require('../controllers/order');

router.post('/checkout', authMiddleware, checkout);
router.get('/', authMiddleware, getOrders);
router.get('/:orderId', authMiddleware, getOrderDetail);

module.exports = router;
