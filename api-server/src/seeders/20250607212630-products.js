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
    const electronics = (await queryInterface.sequelize.query(
        `SELECT id FROM "ProductCategories" WHERE name = 'Electronics' LIMIT 1;`,
        { type: Sequelize.QueryTypes.SELECT }
    ))[0];
    const foodBeverages = (await queryInterface.sequelize.query(
        `SELECT id FROM "ProductCategories" WHERE name = 'Food & Beverages' LIMIT 1;`,
        { type: Sequelize.QueryTypes.SELECT }
    ))[0];
    const homeAppliances = (await queryInterface.sequelize.query(
        `SELECT id FROM "ProductCategories" WHERE name = 'Home Appliances' LIMIT 1;`,
        { type: Sequelize.QueryTypes.SELECT }
    ))[0];
    const clothingAccessories = (await queryInterface.sequelize.query(
        `SELECT id FROM "ProductCategories" WHERE name = 'Clothing & Accessories' LIMIT 1;`,
        { type: Sequelize.QueryTypes.SELECT }
    ))[0];

    await queryInterface.bulkInsert('Products', [
      {
        name: 'Product 1',
        description: 'Description for Product 1',
        image: 'http://localhost:4000/assets/p1.jpg',
        price: 19.99,
        brand: 'Brand A',
        category_id: electronics.id,
        stock: 20,
        createdAt: new Date(),
        updatedAt: new Date(),
      },
      {
        name: 'Product 2',
        description: 'Description for Product 2',
        image: 'http://localhost:4000/assets/p2.jpg',
        price: 300.99,
        brand: 'Brand b',
        category_id: foodBeverages.id,
        stock: 2,
        createdAt: new Date(),
        updatedAt: new Date(),
      },
      {
        name: 'Product 3',
        description: 'Description for Product 3',
        image: 'http://localhost:4000/assets/p3.jpg',
        price: 3400.99,
        brand: 'Brand c',
        category_id: homeAppliances.id,
        stock: 20,
        createdAt: new Date(),
        updatedAt: new Date(),
      },
      {
        name: 'Product 4',
        description: 'Description for Product 4',
        image: 'http://localhost:4000/assets/p4.jpg',
        price: 200.99,
        brand: 'Brand c',
        category_id: homeAppliances.id,
        stock: 4,
        createdAt: new Date(),
        updatedAt: new Date(),
      },
      {
        name: 'Product 5',
        description: 'Description for Product 5',
        image: 'http://localhost:4000/assets/p5.jpg',
        price: 1900.99,
        brand: 'Brand c',
        category_id: clothingAccessories.id,
        stock: 14,
        createdAt: new Date(),
        updatedAt: new Date(),
      },

    ], {});
  },

  async down (queryInterface, Sequelize) {
    /**
     * Add commands to revert seed here.
     *
     * Example:
     * await queryInterface.bulkDelete('People', null, {});
     */
    await queryInterface.bulkDelete('Products', null, {});
  }
};
