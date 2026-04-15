'use strict';
const { Model, DataTypes } = require('sequelize');
require('dotenv').config();

module.exports = (sequelize) => {
    class ProductImage extends Model {
        static associate(models) {
            // Define associations here if needed, e.g.,
            ProductImage.belongsTo(models.Product, {
                foreignKey: 'product_id',
                as: 'product'
            });
        }
    }

    ProductImage.init(
        {
            image: {
                type: DataTypes.STRING(500),
                allowNull: false,
            },
            product_id: {
                type: DataTypes.UUIDV4,
                allowNull: false,
            },
        },
        {
            sequelize,
            modelName: 'ProductImage',
            tableName: 'ProductImages',
            timestamps: true,
            underscored: false,
        }
    );

    return ProductImage;
};
