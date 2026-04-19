'use strict';
const { Cart, Product } = require('../models');
const { sendSuccess, sendServerError, sendValidationErrors, sendNotFoundError } = require('../helpers/response');
const { validate } = require('../helpers/validate');

const getCart = async (req, res) => {
    try {
        const items = await Cart.findAll({
            where: { userId: req.user.id },
            include: [
                {
                    model: Product,
                    as: 'product',
                    attributes: ['id', 'name', 'price', 'image', 'brand', 'stock'],
                },
            ],
            order: [['createdAt', 'ASC']],
        });

        const totalPrice = items.reduce((sum, item) => {
            return sum + parseFloat(item.product.price) * item.quantity;
        }, 0);

        return sendSuccess({
            res,
            message: 'Cart fetched successfully',
            data: {
                items,
                totalItems: items.length,
                totalPrice: parseFloat(totalPrice.toFixed(2)),
            },
        });
    } catch (e) {
        return sendServerError({ res, message: e.message });
    }
};

const addToCart = async (req, res) => {
    try {
        const errors = validate(req.body, {
            productId: { presence: { allowEmpty: false } },
            quantity: { numericality: { onlyInteger: true, greaterThan: 0, allowBlank: true } },
        });
        if (errors) return sendValidationErrors({ res, errors });

        const { productId, quantity = 1 } = req.body;

        const product = await Product.findByPk(productId);
        if (!product) return sendNotFoundError({ res, message: 'Product not found' });

        const [cartItem, created] = await Cart.findOrCreate({
            where: { userId: req.user.id, productId },
            defaults: { quantity },
        });

        if (!created) {
            cartItem.quantity += quantity;
            await cartItem.save();
        }

        return sendSuccess({
            res,
            message: created ? 'Item added to cart' : 'Cart item quantity updated',
            data: cartItem,
        });
    } catch (e) {
        return sendServerError({ res, message: e.message });
    }
};

const updateCartItem = async (req, res) => {
    try {
        const { productId } = req.params;
        const errors = validate(req.body, {
            quantity: {
                presence: { allowEmpty: false },
                numericality: { onlyInteger: true, greaterThan: 0 },
            },
        });
        if (errors) return sendValidationErrors({ res, errors });

        const cartItem = await Cart.findOne({ where: { userId: req.user.id, productId } });
        if (!cartItem) return sendNotFoundError({ res, message: 'Cart item not found' });

        cartItem.quantity = req.body.quantity;
        await cartItem.save();

        return sendSuccess({ res, data: cartItem, message: 'Cart item updated' });
    } catch (e) {
        return sendServerError({ res, message: e.message });
    }
};

const removeCartItem = async (req, res) => {
    try {
        const { productId } = req.params;
        const deleted = await Cart.destroy({ where: { userId: req.user.id, productId } });
        if (!deleted) return sendNotFoundError({ res, message: 'Cart item not found' });
        return sendSuccess({ res, data: { productId }, message: 'Cart item removed' });
    } catch (e) {
        return sendServerError({ res, message: e.message });
    }
};

module.exports = { getCart, addToCart, updateCartItem, removeCartItem };