const express = require('express');
const router = express.Router();
const authMiddleware = require('../middleware/auth');
const { getCart, addToCart, updateCartItem, removeCartItem } = require('../controllers/cart');

router.get('/', authMiddleware, getCart);
router.post('/add', authMiddleware, addToCart);
router.patch('/:productId', authMiddleware, updateCartItem);
router.delete('/:productId', authMiddleware, removeCartItem);

module.exports = router;