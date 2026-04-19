'use strict';
const { Model, DataTypes } = require('sequelize');

module.exports = (sequelize) => {
    class Cart extends Model {
        static associate(models) {
            Cart.belongsTo(models.User, { foreignKey: 'userId', as: 'user' });
            Cart.belongsTo(models.Product, { foreignKey: 'productId', as: 'product' });
        }
    }

    Cart.init(
        {
            userId: {
                type: DataTypes.UUID,
                allowNull: false,
            },
            productId: {
                type: DataTypes.UUID,
                allowNull: false,
            },
            quantity: {
                type: DataTypes.INTEGER,
                allowNull: false,
                defaultValue: 1,
            },
        },
        {
            sequelize,
            modelName: 'Cart',
            tableName: 'Carts',
            timestamps: true,
        }
    );

    return Cart;
};