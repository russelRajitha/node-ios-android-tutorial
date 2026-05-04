const express = require('express');
const router = express.Router();
const authMiddleware = require('../middleware/auth');
const { getNotifications, markRead } = require('../controllers/notification');

router.get('/', authMiddleware, getNotifications);
router.patch('/:id/read', authMiddleware, markRead);

module.exports = router;
