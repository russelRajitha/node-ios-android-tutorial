const express = require('express');
const router = express.Router();
const authMiddleware = require('../middleware/auth');
const { registerToken, unregisterToken } = require('../controllers/deviceToken');

router.post('/', authMiddleware, registerToken);
router.delete('/', authMiddleware, unregisterToken);

module.exports = router;
