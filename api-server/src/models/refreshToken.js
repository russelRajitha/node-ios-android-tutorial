'use strict';
const { Model, DataTypes } = require('sequelize');

module.exports = (sequelize) => {
    class RefreshToken extends Model {
        static associate(models) {
            RefreshToken.belongsTo(models.User, { foreignKey: 'userId', as: 'user' });
        }

        isExpired() {
            return new Date() > new Date(this.expiresAt);
        }

        isExhausted() {
            return this.useCount >= this.maxUseCount;
        }

        isValid() {
            return !this.revokedAt && !this.isExpired() && !this.isExhausted();
        }
    }

    RefreshToken.init(
        {
            jti: {
                type: DataTypes.STRING(36),
                allowNull: false,
                unique: true,
            },
            userId: {
                type: DataTypes.UUID,
                allowNull: false,
            },
            useCount: {
                type: DataTypes.INTEGER,
                allowNull: false,
                defaultValue: 0,
            },
            maxUseCount: {
                type: DataTypes.INTEGER,
                allowNull: false,
            },
            expiresAt: {
                type: DataTypes.DATE,
                allowNull: false,
            },
            revokedAt: {
                type: DataTypes.DATE,
                allowNull: true,
                defaultValue: null,
            },
        },
        {
            sequelize,
            modelName: 'RefreshToken',
            tableName: 'RefreshTokens',
            timestamps: true,
            underscored: false,
        }
    );

    return RefreshToken;
};