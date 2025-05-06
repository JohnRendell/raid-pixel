const express = require("express");
const sceneModel = require("./sceneMongooseSchema");
const route = express.Router();

route.post("/scene_cycle", async (req, res)=>{
    try{
        const find_scene = await sceneModel.findOne({ scene_name: req.body.scene_name })

        let status = "Failed";
        let scene_name = "Not found";
        let time = 0;
        let time_max = 0;

        if(find_scene){
            status = "Success";
            scene_name = find_scene.scene_name;
            time = find_scene.time;
            time_max = find_scene.time_max;
        }

        res.status(200).json({ status: status, scene_name: scene_name, time: time, time_max: time_max })
    }
    catch(err){
        console.log(err)
    }
});

module.exports = route;