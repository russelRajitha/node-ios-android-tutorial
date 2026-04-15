const sendValidationErrors = ({errors, res,message = "Invalid Input"}) => {
    return res.status(400).json({message, errors, data: null, success: false});
}
const sendServerError = ({message = 'Internal Server Error', res}) => {
    return res.status(500).json({message, errors: {}, data: null, success: false});
}

const sendSuccess = ({data, res, message = 'Success'}) => {
    return res.status(200).json({message, errors: {}, data, success: true});
}

const sendAuthError = ({res, message = 'Unauthorized Request'}) => {
    return res.status(401).json({message, errors: {}, data: null, success: false});
}
const sendNotFoundError = ({res, message = 'Page not found!'}) => {
    return res.status(404).json({message, errors: {}, data: null, success: false});
}

module.exports = {
    sendValidationErrors,
    sendServerError,
    sendSuccess,
    sendAuthError,
    sendNotFoundError,
};
