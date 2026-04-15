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
    await queryInterface.bulkInsert('ProductCategories', [
      {
        name: 'Electronics',
        icon: 'http://localhost:4000/assets/electronics.png',
      },
      {
        name: 'Food & Beverages',
        icon: 'http://localhost:4000/assets/food_beverages.png',
      },
      {
        name: 'Home Appliances',
        icon: 'http://localhost:4000/assets/home_appliances.png',
      },
      {
        name: 'Clothing & Accessories',
        icon: 'http://localhost:4000/assets/clothing_accessories.png',
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
    await queryInterface.bulkDelete('ProductCategories', null, {});
  }
};
