const { sendSuccess, sendServerError, sendValidationErrors } = require('../helpers/response');
const { validate } = require('../helpers/validate');
const { ProductCategory, Product } = require('../models');

const categories = async (req, res) => {
    try {
        const rows = await ProductCategory.findAll({
            attributes: ['id', 'name', 'icon'],
            order: [['name', 'ASC']],
        });
        return sendSuccess({ res, data: { categories: rows } });
    } catch (e) {
        return sendServerError({ res, message: e.message });
    }
};

const category = async (req, res) => {
    try {
        const errors = validate(req.params, {
            category_id: {
                presence: { allowEmpty: false },
                uuidv4: true,
            },
        });
        if (errors) return sendValidationErrors({ res, errors });

        const data = await ProductCategory.findOne({
            where: { id: req.params.category_id },
            attributes: ['id', 'name', 'icon'],
        });
        if (!data) {
            return sendValidationErrors({
                res,
                errors: { category_id: ['Invalid Category ID'] },
            });
        }

        const { page = 1, pageSize = 10 } = req.query;
        const limit = parseInt(pageSize, 10);
        const offset = (parseInt(page, 10) - 1) * limit;

        const { count, rows: products } = await Product.findAndCountAll({
            where: { category_id: req.params.category_id },
            attributes: ['id', 'name', 'price', 'image'],
            limit,
            offset,
            order: [['createdAt', 'DESC']],
        });

        return sendSuccess({
            res,
            data: {
                category: data,
                products,
                count,
            },
        });
    } catch (e) {
        return sendServerError({ res, message: e.message });
    }
};

module.exports = { categories, category };
