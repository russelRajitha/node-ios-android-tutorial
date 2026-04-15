const express = require('express');
const router = express.Router();
const productController = require('../controllers/product');

router.get('/all', productController.products);
router.get('/:product_id', productController.product);

module.exports = router;
