'use strict';
const { DeviceToken } = require('../models');
const { sendSuccess, sendServerError, sendValidationErrors } = require('../helpers/response');
const { validate } = require('../helpers/validate');

const registerToken = async (req, res) => {
    try {
        const errors = validate(req.body, {
            token: { presence: { allowEmpty: false } },
            platform: { presence: { allowEmpty: false }, inclusion: { within: ['ios', 'android'], message: 'must be "ios" or "android"' } },
        });
        if (errors) return sendValidationErrors({ res, errors });

        const { token, platform } = req.body;
        const existing = await DeviceToken.findOne({ where: { token } });

        if (existing) {
            // Reassign to current user if the same device token re-registers under a different account.
            await existing.update({ userId: req.user.id, platform });
            return sendSuccess({ res, message: 'Device token registered', data: existing });
        }

        const record = await DeviceToken.create({ userId: req.user.id, token, platform });
        return sendSuccess({ res, message: 'Device token registered', data: record });
    } catch (e) {
        return sendServerError({ res, message: e.message });
    }
};

const unregisterToken = async (req, res) => {
    try {
        const errors = validate(req.body, {
            token: { presence: { allowEmpty: false } },
        });
        if (errors) return sendValidationErrors({ res, errors });

        const { token } = req.body;
        const deleted = await DeviceToken.destroy({ where: { token, userId: req.user.id } });
        return sendSuccess({ res, message: deleted ? 'Device token removed' : 'Token not found', data: null });
    } catch (e) {
        return sendServerError({ res, message: e.message });
    }
};

module.exports = { registerToken, unregisterToken };
