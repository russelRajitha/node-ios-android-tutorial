'use strict';
const { Model, DataTypes } = require('sequelize');

module.exports = (sequelize) => {
    class Order extends Model {
        static associate(models) {
            Order.belongsTo(models.User, { foreignKey: 'userId', as: 'user' });
            Order.hasMany(models.OrderItem, { foreignKey: 'orderId', as: 'items' });
            Order.hasMany(models.Notification, { foreignKey: 'orderId', as: 'notifications' });
        }
    }

    Order.init(
        {
            userId: {
                type: DataTypes.UUID,
                allowNull: false,
            },
            orderNumber: {
                type: DataTypes.STRING(20),
                allowNull: false,
                unique: true,
            },
            status: {
                type: DataTypes.ENUM('processing', 'delivered'),
                allowNull: false,
                defaultValue: 'processing',
            },
            total: {
                type: DataTypes.DECIMAL(10, 2),
                allowNull: false,
            },
        },
        {
            sequelize,
            modelName: 'Order',
            tableName: 'Orders',
            timestamps: true,
        }
    );

    return Order;
};
