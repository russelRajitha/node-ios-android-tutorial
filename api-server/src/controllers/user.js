const { sendSuccess, sendServerError} = require('../helpers/response');
const { User } = require('../models');

const profile = async (req, res) => {
    try {
        const user = await User.findByPk(req.user.id, {
            attributes: ['id', 'firstName', 'lastName', 'email', 'createdAt'],
        });
        return sendSuccess({ res, data: user, message: 'Profile fetched successfully' });
    } catch (e) {
        return sendServerError({ res, message: e.message });
    }
};

module.exports = { profile };