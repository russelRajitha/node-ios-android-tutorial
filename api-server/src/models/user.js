'use strict';
const { Model, DataTypes } = require('sequelize');
const jwt = require('jsonwebtoken');
const moment = require("moment-timezone");
const { v4: uuidv4 } = require('uuid');

const parseTTLToDate = (ttl) => {
    const num = parseInt(ttl, 10);
    const unit = ttl.slice(-1);
    const unitMap = { s: 'seconds', m: 'minutes', h: 'hours', d: 'days' };
    return moment().add(num, unitMap[unit] ?? 'days').toDate();
};


module.exports = (sequelize) => {
    class User extends Model {
        static associate(models) {
            User.hasMany(models.RefreshToken, { foreignKey: 'userId', as: 'refreshTokens' });
            User.hasMany(models.Cart, { foreignKey: 'userId', as: 'cartItems' });
            User.hasMany(models.Order, { foreignKey: 'userId', as: 'orders' });
            User.hasMany(models.Notification, { foreignKey: 'userId', as: 'notifications' });
            User.hasMany(models.DeviceToken, { foreignKey: 'userId', as: 'deviceTokens' });
        }
        async issueRefreshToken () {
            const jti = uuidv4();
            const ttl = process.env.JWT_REFRESH_EXPIRES_IN || '7d';
            const maxUseCount = parseInt(process.env.MAX_REFRESH_COUNT || '10', 10);
            const token = jwt.sign(
                {
                    id: this.id,
                    jti,
                },
                process.env.JWT_REFRESH_SECRET || process.env.JWT_SECRET,
                {
                    expiresIn: ttl,
                }
            );
            await sequelize.models.RefreshToken.create({
                jti,
                userId: this.id,
                useCount: 0,
                maxUseCount,
                expiresAt: parseTTLToDate(ttl),
            });
            return token;
        };

        generateAccessToken() {
            return jwt.sign(
                { id: this.id, email: this.email },
                process.env.JWT_ACCESS_SECRET || process.env.JWT_SECRET,
                { expiresIn: process.env.JWT_ACCESS_EXPIRES_IN || '15m' }
            );
        }

        generateAuthToken() {
            return this.generateAccessToken();
        }
    }

    User.init(
        {
            firstName: {
                type: DataTypes.STRING,
                allowNull: false,
            },
            lastName: {
                type: DataTypes.STRING,
                allowNull: false,
            },
            email: {
                type: DataTypes.STRING,
                allowNull: false,
                unique: true,
            },
            password: {
                type: DataTypes.STRING,
                allowNull: false,
            },
        },
        {
            sequelize,
            modelName: 'User',
            tableName: 'Users',
            timestamps: true,
            underscored: false,
        }
    );

    return User;
};