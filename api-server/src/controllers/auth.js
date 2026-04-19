const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { UniqueConstraintError } = require('sequelize');
const { sendSuccess, sendServerError, sendValidationErrors, sendAuthError } = require('../helpers/response');
const { validate } = require('../helpers/validate');
const { User, RefreshToken } = require('../models');

const login = async (req, res) => {
    try {
        const errors = validate(req.body, {
            email: {
                presence: { allowEmpty: false },
                email: true,
            },
            password: {
                presence: { allowEmpty: false },
            },
        });
        if (errors) {
            return sendValidationErrors({ res, errors });
        }

        const user = await User.findOne({ where: { email: req.body.email } });
        if (!user) {
            return sendAuthError({ res, message: 'Invalid email or password' });
        }

        const isMatch = await bcrypt.compare(req.body.password, user.password);
        if (!isMatch) {
            return sendAuthError({ res, message: 'Invalid email or password' });
        }

        const accessToken = user.generateAccessToken();
        const refreshToken = await user.issueRefreshToken();

        return sendSuccess({
            res,
            data: { accessToken, refreshToken },
            message: 'Login successful',
        });
    } catch (e) {
        return sendServerError({ res, message: e.message });
    }
};

const signUp = async (req, res) => {
    try {
        const errors = validate(req.body, {
            firstName: { presence: { allowEmpty: false } },
            lastName: { presence: { allowEmpty: false } },
            email: {
                presence: { allowEmpty: false },
                email: true,
            },
            password: {
                presence: { allowEmpty: false },
                length: { minimum: 6 },
            },
        });
        if (errors) {
            return sendValidationErrors({ res, errors });
        }

        const existing = await User.findOne({ where: { email: req.body.email } });
        if (existing) {
            return sendValidationErrors({ res, errors: { email: ['Email is already in use'] } });
        }

        const hashedPassword = await bcrypt.hash(req.body.password, 10);
        const user = await User.create({
            firstName: req.body.firstName,
            lastName: req.body.lastName,
            email: req.body.email,
            password: hashedPassword,
        });

        const accessToken = user.generateAccessToken();
        const refreshToken = await user.issueRefreshToken(user);

        return sendSuccess({
            res,
            data: { accessToken, refreshToken },
            message: 'Account created successfully',
        });
    } catch (e) {
        if (e instanceof UniqueConstraintError) {
            return sendValidationErrors({ res, errors: { email: ['Email is already in use'] } });
        }
        return sendServerError({ res, message: e.message });
    }
};

const refresh = async (req, res) => {
    const { refreshToken } = req.body;
    if (!refreshToken) {
        return sendAuthError({ res, message: 'Refresh token required' });
    }

    try {
        const payload = jwt.verify(
            refreshToken,
            process.env.JWT_REFRESH_SECRET || process.env.JWT_SECRET
        );

        const record = await RefreshToken.findOne({
            where: { jti: payload.jti, revokedAt: null },
        });

        if (!record || !record.isValid()) {
            return sendAuthError({ res, message: 'Invalid or expired refresh token' });
        }

        await record.increment('useCount');

        const user = await User.findByPk(payload.id);
        if (!user) return sendAuthError({ res, message: 'User not found' });

        const newAccessToken = user.generateAccessToken();

        return sendSuccess({
            res,
            data: { accessToken: newAccessToken },
            message: 'Token refreshed successfully',
        });
    } catch (e) {
        return sendAuthError({ res, message: 'Invalid or expired refresh token' });
    }
};

const logout = async (req, res) => {
    const { refreshToken } = req.body;

    if (refreshToken) {
        try {
            const payload = jwt.verify(
                refreshToken,
                process.env.JWT_REFRESH_SECRET || process.env.JWT_SECRET
            );
            await RefreshToken.update(
                { revokedAt: new Date() },
                { where: { jti: payload.jti } }
            );
        } catch {
            // Best-effort revocation — ignore invalid / already-expired tokens
        }
    }

    return sendSuccess({ res, data: null, message: 'Logged out successfully' });
};

module.exports = { login, signUp, refresh, logout };