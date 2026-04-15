'use strict';
const { Model, DataTypes } = require('sequelize');
require('dotenv').config();

module.exports = (sequelize) => {
    class ProductCategory extends Model {
        static associate(models) {
            // Define associations here if needed, e.g.,
            // ProductCategory.belongsTo(models.User, { foreignKey: 'user' });
            ProductCategory.hasMany(models.Product, {
                foreignKey: 'category_id',
                as: 'products'
            });
        }
    }

    ProductCategory.init(
        {
            name: {
                type: DataTypes.STRING(500),
                allowNull: false,
            },
            icon: {
                type: DataTypes.STRING(500),
                allowNull: false,
            },
        },
        {
            sequelize,
            modelName: 'ProductCategory',
            tableName: 'ProductCategories',
            timestamps: true,
            underscored: false,
        }
    );

    return ProductCategory;
};
