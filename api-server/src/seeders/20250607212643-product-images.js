'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up (queryInterface, Sequelize) {
    /**
     * Add seed commands here.
     *
     * Example:
     * await queryInterface.bulkInsert('People', [{
     *   name: 'John Doe',
     *   isBetaMember: false
     * }], {});
     */
    const products = await queryInterface.sequelize.query(
        `SELECT id FROM "Products";`,
        { type: Sequelize.QueryTypes.SELECT }
    );
    for (const product of products) {
      await queryInterface.bulkInsert('ProductImages', [
        {
          image: `http://localhost:4000/assets/p${Math.floor(Math.random() * 5) + 1}.jpg`,
          product_id: product.id,
          createdAt: new Date(),
          updatedAt: new Date(),
        },
        {
          image: `http://localhost:4000/assets/p${Math.floor(Math.random() * 5) + 1}.jpg`,
          product_id: product.id,
          createdAt: new Date(),
          updatedAt: new Date(),
        },
        {
          image: `http://localhost:4000/assets/p${Math.floor(Math.random() * 5) + 1}.jpg`,
          product_id: product.id,
          createdAt: new Date(),
          updatedAt: new Date(),
        },
        {
          image: `http://localhost:4000/assets/p${Math.floor(Math.random() * 5) + 1}.jpg`,
          product_id: product.id,
          createdAt: new Date(),
          updatedAt: new Date(),
        },
        {
          image: `http://localhost:4000/assets/p${Math.floor(Math.random() * 5) + 1}.jpg`,
          product_id: product.id,
          createdAt: new Date(),
          updatedAt: new Date(),
        },
        {
          image: `http://localhost:4000/assets/p${Math.floor(Math.random() * 5) + 1}.jpg`,
          product_id: product.id,
          createdAt: new Date(),
          updatedAt: new Date(),
        },
      ], {});
    }
  },

  async down (queryInterface, Sequelize) {
    /**
     * Add commands to revert seed here.
     *
     * Example:
     * await queryInterface.bulkDelete('People', null, {});
     */
    await queryInterface.bulkDelete('ProductImages', null, {});
  }
};
