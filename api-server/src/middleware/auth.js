const jwt = require('jsonwebtoken');
const { sendAuthError } = require('../helpers/response');

const authMiddleware = (req, res, next) => {
    const authHeader = req.headers['authorization'];
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
        return sendAuthError({ res, message: 'Unauthorized Request' });
    }

    const token = authHeader.split(' ')[1];
    try {
        req.user = jwt.verify(token, process.env.JWT_ACCESS_SECRET || process.env.JWT_SECRET);
        next();
    } catch (e) {
        return sendAuthError({ res, message: 'Unauthorized Request' });
    }
};

module.exports = authMiddleware;