const express = require('express');
const router = express.Router();
const { categories, category } = require('../controllers/productCategory');

router.get('/all', categories);
router.get('/:category_id', category);

module.exports = router;
