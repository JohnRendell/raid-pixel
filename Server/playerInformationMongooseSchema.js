const mongoose = require('mongoose');
const { Schema } = mongoose;

const playerInfoSchema = new Schema({
    username: { type: String, require: true },
    inGameName: { type: String, require: true },
});

const playerInfoModel = mongoose.model("playerInfo", playerInfoSchema);

module.exports = playerInfoModel;
