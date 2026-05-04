'use strict';
const { Model, DataTypes } = require('sequelize');

module.exports = (sequelize) => {
    class Notification extends Model {
        static associate(models) {
            Notification.belongsTo(models.User, { foreignKey: 'userId', as: 'user' });
            Notification.belongsTo(models.Order, { foreignKey: 'orderId', as: 'order' });
        }
    }

    Notification.init(
        {
            userId: {
                type: DataTypes.UUID,
                allowNull: false,
            },
            title: {
                type: DataTypes.STRING(255),
                allowNull: false,
            },
            body: {
                type: DataTypes.STRING(500),
                allowNull: false,
            },
            type: {
                type: DataTypes.STRING(50),
                allowNull: false,
                defaultValue: 'order',
            },
            orderId: {
                type: DataTypes.UUID,
                allowNull: true,
            },
            isRead: {
                type: DataTypes.BOOLEAN,
                allowNull: false,
                defaultValue: false,
            },
        },
        {
            sequelize,
            modelName: 'Notification',
            tableName: 'Notifications',
            timestamps: true,
        }
    );

    return Notification;
};
