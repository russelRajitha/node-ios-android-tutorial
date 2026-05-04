'use strict';
const { Order, Notification } = require('../models');
const { sendSuccess, sendServerError, sendNotFoundError } = require('../helpers/response');
const { sendPushToUser } = require('../services/pushNotification');

/**
 * POST /api/admin/orders/:orderId/deliver
 */
const markDelivered = async (req, res) => {
    try {
        const order = await Order.findByPk(req.params.orderId);
        if (!order) return sendNotFoundError({ res, message: 'Order not found' });

        if (order.status === 'delivered') {
            return sendSuccess({ res, message: 'Order already delivered', data: order });
        }

        order.status = 'delivered';
        await order.save();

        const notifTitle = 'Order Delivered';
        const notifBody = `Your order ${order.orderNumber} has been delivered.`;

        await Notification.create({
            userId: order.userId,
            title: notifTitle,
            body: notifBody,
            type: 'order',
            orderId: order.id,
            isRead: false,
        });

        sendPushToUser(order.userId, notifTitle, notifBody, {
            type: 'order',
            orderId: order.id,
            orderNumber: order.orderNumber,
        });

        return sendSuccess({ res, message: 'Order marked as delivered', data: order });
    } catch (e) {
        return sendServerError({ res, message: e.message });
    }
};

module.exports = { markDelivered };
