'use strict';
const { Model, DataTypes } = require('sequelize');
require('dotenv').config();

module.exports = (sequelize) => {
    class Product extends Model {
        static associate(models) {
            Product.hasMany(models.ProductImage, { foreignKey: 'product_id', as: 'images' });
            Product.belongsTo(models.ProductCategory, { foreignKey: 'category_id', as: 'category' });
            Product.hasMany(models.Cart, { foreignKey: 'productId', as: 'cartItems' });
        }
    }

    Product.init(
        {
            name: {
                type: DataTypes.STRING(500),
                allowNull: false,
            },
            description: {
                type: DataTypes.STRING(500),
                allowNull: false,
            },
            image: {
                type: DataTypes.STRING(500),
                allowNull: true,
            },
            price: {
                type: DataTypes.DECIMAL(10, 2),
                allowNull: true,
            },
            brand: {
                type: DataTypes.STRING(500),
                allowNull: false,
            },
            stock: {
                type: DataTypes.DECIMAL(10),
                allowNull: false,
            },
            category_id: {
                type: DataTypes.UUIDV4,
                allowNull: false,
            },
        },
        {
            sequelize,
            modelName: 'Product',
            tableName: 'Products',
            timestamps: true,
            underscored: false,
        }
    );

    return Product;
};
