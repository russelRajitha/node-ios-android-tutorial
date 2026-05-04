'use strict';
const { Cart, Product, Order, OrderItem, Notification } = require('../models');
const { sendSuccess, sendServerError, sendNotFoundError, sendValidationErrors } = require('../helpers/response');
const { validate } = require('../helpers/validate');
const { sendPushToUser } = require('../services/pushNotification');

const generateOrderNumber = async () => {
    const count = await Order.count();
    return `ORD-${String(count + 1).padStart(8, '0')}`;
};

const checkout = async (req, res) => {
    try {
        const cartItems = await Cart.findAll({
            where: { userId: req.user.id },
            include: [{ model: Product, as: 'product', attributes: ['id', 'name', 'image', 'price'] }],
        });

        if (!cartItems.length) {
            return sendNotFoundError({ res, message: 'Cart is empty' });
        }

        const total = cartItems.reduce((sum, item) => {
            return sum + parseFloat(item.product.price) * item.quantity;
        }, 0);

        const orderNumber = await generateOrderNumber();

        const order = await Order.create({
            userId: req.user.id,
            orderNumber,
            status: 'processing',
            total: parseFloat(total.toFixed(2)),
        });

        await OrderItem.bulkCreate(
            cartItems.map((item) => ({
                orderId: order.id,
                productId: item.productId,
                productName: item.product.name,
                productImage: item.product.image,
                productPrice: parseFloat(item.product.price),
                quantity: item.quantity,
            }))
        );

        await Cart.destroy({ where: { userId: req.user.id } });

        const notificationTitle = 'Order placed';
        const notificationBody = `Your order ${orderNumber} has been placed successfully.`;

        await Notification.create({
            userId: req.user.id,
            title: notificationTitle,
            body: notificationBody,
            type: 'order',
            orderId: order.id,
        });

        sendPushToUser(req.user.id, notificationTitle, notificationBody, { orderId: order.id }).catch(() => {});

        const orderWithItems = await Order.findByPk(order.id, {
            include: [{ model: OrderItem, as: 'items' }],
        });

        return sendSuccess({ res, message: 'Order placed successfully', data: orderWithItems });
    } catch (e) {
        return sendServerError({ res, message: e.message });
    }
};

const getOrders = async (req, res) => {
    try {
        const orders = await Order.findAll({
            where: { userId: req.user.id },
            order: [['createdAt', 'DESC']],
        });

        return sendSuccess({ res, message: 'Orders fetched successfully', data: orders });
    } catch (e) {
        return sendServerError({ res, message: e.message });
    }
};

const getOrderDetail = async (req, res) => {
    try {
        const errors = validate({ orderId: req.params.orderId }, {
            orderId: { presence: { allowEmpty: false }, uuidv4: true },
        });
        if (errors) return sendValidationErrors({ res, errors });

        const order = await Order.findOne({
            where: { id: req.params.orderId, userId: req.user.id },
            include: [{ model: OrderItem, as: 'items' }],
        });

        if (!order) return sendNotFoundError({ res, message: 'Order not found' });

        return sendSuccess({ res, message: 'Order fetched successfully', data: order });
    } catch (e) {
        return sendServerError({ res, message: e.message });
    }
};

module.exports = { checkout, getOrders, getOrderDetail };
