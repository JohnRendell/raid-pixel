const mongoose = require('mongoose');
const { Schema } = mongoose;

const sceneSchema = new Schema({
    scene_name: { type: String, require: true },
    time: { type: Number, require: true }
});

const sceneModel = mongoose.model("scene", sceneSchema);

module.exports = sceneModel;
