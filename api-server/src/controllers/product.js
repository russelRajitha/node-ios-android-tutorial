const {sendSuccess, sendServerError,sendValidationErrors} = require("../helpers/response");
const {validate} = require("../helpers/validate");
const {Product} = require("./../models");

const products = async (req, res) => {
    try {
        const {page = 1, pageSize = 10} = req.query;
        const limit = parseInt(pageSize, 10);
        const offset = (parseInt(page, 10) - 1) * limit;
        const {count, rows} = await Product.findAndCountAll({
            attributes: ['id', 'name', 'price', 'image'],
            limit,
            offset,
            order: [['createdAt', 'DESC']]
        });
        return sendSuccess({
            data: {
                products: rows,
                count,
            }, res
        });
    } catch (e) {
        return sendServerError({res, message: e.message});
    }
};

const product = async (req, res) => {
    try {
        const errors = validate(req.params, {
            product_id: {
                presence: {
                    allowEmpty: false
                },
                uuidv4: true
            },
        });
        if (errors) {
            return sendValidationErrors({res, errors});
        }
        let data = await Product.findOne({
            where: {
                id: req.params.product_id
            },
            include:['category', 'images'],
        });
        if (!data) {
            return sendValidationErrors({
                res, errors: {
                    product_id: ['Invalid Product ID']
                }
            });
        }
        return sendSuccess({
            data: {
                product: data,
            }, res
        });
    } catch (e) {
        return sendServerError({res, message: e.message});
    }
};

module.exports = {
    products,
    product,
};
