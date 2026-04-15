const validate = require("validate.js");


// Add custom validator to validate.js
validate.validators.uuidv4 = function(value, options, key, attributes) {
  const reg = new RegExp(/^[0-9A-F]{8}-[0-9A-F]{4}-4[0-9A-F]{3}-[89AB][0-9A-F]{3}-[0-9A-F]{12}$/i)
  if (!reg.test(value)) {
    return options.message || 'is not a valid UUIDv4';
  }
};

module.exports = {
  validate,
}
