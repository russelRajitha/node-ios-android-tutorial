const express = require('express');
const router = express.Router();
const { login, signUp, refresh, logout } = require('../controllers/auth');

router.post('/login', login);
router.post('/sign-up', signUp);
router.post('/refresh', refresh);
router.post('/logout', logout);

module.exports = router;
