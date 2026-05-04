'use strict';
const { Notification } = require('../models');
const { sendSuccess, sendServerError, sendNotFoundError, sendValidationErrors } = require('../helpers/response');
const { validate } = require('../helpers/validate');

const getNotifications = async (req, res) => {
    try {
        const notifications = await Notification.findAll({
            where: { userId: req.user.id },
            order: [['createdAt', 'DESC']],
        });

        return sendSuccess({ res, message: 'Notifications fetched successfully', data: notifications });
    } catch (e) {
        return sendServerError({ res, message: e.message });
    }
};

const markRead = async (req, res) => {
    try {
        const errors = validate({ id: req.params.id }, {
            id: { presence: { allowEmpty: false }, uuidv4: true },
        });
        if (errors) return sendValidationErrors({ res, errors });

        const notification = await Notification.findOne({
            where: { id: req.params.id, userId: req.user.id },
        });

        if (!notification) return sendNotFoundError({ res, message: 'Notification not found' });

        notification.isRead = true;
        await notification.save();

        return sendSuccess({ res, message: 'Notification marked as read', data: notification });
    } catch (e) {
        return sendServerError({ res, message: e.message });
    }
};

module.exports = { getNotifications, markRead };
