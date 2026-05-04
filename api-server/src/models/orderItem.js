'use strict';
const { Model, DataTypes } = require('sequelize');

module.exports = (sequelize) => {
    class OrderItem extends Model {
        static associate(models) {
            OrderItem.belongsTo(models.Order, { foreignKey: 'orderId', as: 'order' });
            OrderItem.belongsTo(models.Product, { foreignKey: 'productId', as: 'product' });
        }
    }

    OrderItem.init(
        {
            orderId: {
                type: DataTypes.UUID,
                allowNull: false,
            },
            productId: {
                type: DataTypes.UUID,
                allowNull: true,
            },
            productName: {
                type: DataTypes.STRING(500),
                allowNull: false,
            },
            productImage: {
                type: DataTypes.STRING(500),
                allowNull: true,
            },
            productPrice: {
                type: DataTypes.DECIMAL(10, 2),
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
            modelName: 'OrderItem',
            tableName: 'OrderItems',
            timestamps: true,
        }
    );

    return OrderItem;
};
