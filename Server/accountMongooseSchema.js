const mongoose = require('mongoose');
const { Schema } = mongoose;

const accountSchema = new Schema({
    username: { type: String, require: true },
    password: { type: String, require: true }
});

const accountModel = mongoose.model("account", accountSchema);

module.exports = accountModel;
