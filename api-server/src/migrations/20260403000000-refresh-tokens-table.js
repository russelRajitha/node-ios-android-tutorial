'use strict';

module.exports = {
    async up(queryInterface, Sequelize) {
        await queryInterface.createTable('RefreshTokens', {
            id: {
                allowNull: false,
                autoIncrement: true,
                primaryKey: true,
                type: Sequelize.INTEGER,
            },
            jti: {
                type: Sequelize.STRING(36),
                allowNull: false,
                unique: true,
            },
            userId: {
                type: Sequelize.UUID,
                allowNull: false,
                references: {
                    model: 'Users',
                    key: 'id',
                },
                onDelete: 'CASCADE',
            },
            useCount: {
                type: Sequelize.INTEGER,
                allowNull: false,
                defaultValue: 0,
            },
            maxUseCount: {
                type: Sequelize.INTEGER,
                allowNull: false,
            },
            expiresAt: {
                type: Sequelize.DATE,
                allowNull: false,
            },
            revokedAt: {
                type: Sequelize.DATE,
                allowNull: true,
                defaultValue: null,
            },
            createdAt: {
                allowNull: false,
                type: Sequelize.DATE,
                defaultValue: Sequelize.literal('CURRENT_TIMESTAMP'),
            },
            updatedAt: {
                allowNull: false,
                type: Sequelize.DATE,
                defaultValue: Sequelize.literal('CURRENT_TIMESTAMP'),
            },
        });

        await queryInterface.addIndex('RefreshTokens', ['userId'], {
            name: 'refresh_tokens_user_id_idx',
        });
    },

    async down(queryInterface) {
        await queryInterface.dropTable('RefreshTokens');
    },
};