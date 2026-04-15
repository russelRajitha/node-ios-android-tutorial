'use strict';
const { Model, DataTypes } = require('sequelize');
const jwt = require('jsonwebtoken');

module.exports = (sequelize) => {
    class User extends Model {
        static associate(models) {}

        generateAuthToken() {
            return jwt.sign(
                { id: this.id, email: this.email },
                process.env.JWT_SECRET,
                { expiresIn: process.env.JWT_EXPIRES_IN || '7d' }
            );
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