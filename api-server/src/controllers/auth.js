const bcrypt = require('bcryptjs');
const { UniqueConstraintError } = require('sequelize');
const { sendSuccess, sendServerError, sendValidationErrors, sendAuthError } = require('../helpers/response');
const { validate } = require('../helpers/validate');
const { User } = require('../models');

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

        const token = user.generateAuthToken();
        return sendSuccess({
            res,
            data: { accessToken: token },
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

        const token = user.generateAuthToken();
        return sendSuccess({
            res,
            data: { accessToken: token },
            message: 'Account created successfully',
        });
    } catch (e) {
        if (e instanceof UniqueConstraintError) {
            return sendValidationErrors({ res, errors: { email: ['Email is already in use'] } });
        }
        return sendServerError({ res, message: e.message });
    }
};

module.exports = { login, signUp };