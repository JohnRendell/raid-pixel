const mongoose = require('mongoose');
const { Schema } = mongoose;

const accountSchema = new Schema({
    username: { type: String, require: true },
    password: { type: String, require: true },
    account_type: { type: String, require: true },
    login_token: { type: String, require: true },
    isOnline: { type: Boolean, require: true }
});

const accountModel = mongoose.model("account", accountSchema);

module.exports = accountModel;
