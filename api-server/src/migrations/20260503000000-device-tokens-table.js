'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
    async up(queryInterface, Sequelize) {
        await queryInterface.createTable('DeviceTokens', {
            id: {
                allowNull: false,
                primaryKey: true,
                type: Sequelize.UUID,
                defaultValue: Sequelize.literal('uuid_generate_v4()'),
            },
            userId: {
                type: Sequelize.UUID,
                allowNull: false,
                references: { model: 'Users', key: 'id' },
                onUpdate: 'CASCADE',
                onDelete: 'CASCADE',
            },
            token: {
                type: Sequelize.STRING(512),
                allowNull: false,
                unique: true,
            },
            platform: {
                type: Sequelize.ENUM('ios', 'android'),
                allowNull: false,
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

        await queryInterface.addIndex('DeviceTokens', ['userId']);
    },

    async down(queryInterface) {
        await queryInterface.dropTable('DeviceTokens');
        await queryInterface.sequelize.query('DROP TYPE IF EXISTS "enum_DeviceTokens_platform";');
    },
};
