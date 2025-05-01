const mongoose = require('mongoose');
const { Schema } = mongoose;

const gameDataSchema = new Schema({
    playerCount: { type: Number, require: true },
});

const gameDataModel = mongoose.model("gameData", gameDataSchema);

module.exports = gameDataModel;
