'use strict';
const { Model, DataTypes } = require('sequelize');

module.exports = (sequelize) => {
    class DeviceToken extends Model {
        static associate(models) {
            DeviceToken.belongsTo(models.User, { foreignKey: 'userId', as: 'user' });
        }
    }

    DeviceToken.init(
        {
            userId: {
                type: DataTypes.UUID,
                allowNull: false,
            },
            token: {
                type: DataTypes.STRING(512),
                allowNull: false,
                unique: true,
            },
            platform: {
                type: DataTypes.ENUM('ios', 'android'),
                allowNull: false,
            },
        },
        {
            sequelize,
            modelName: 'DeviceToken',
            tableName: 'DeviceTokens',
            timestamps: true,
        }
    );

    return DeviceToken;
};
