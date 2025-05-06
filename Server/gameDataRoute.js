const express = require("express");
const gameDataModel = require("./gameDataMongooseSchema");
const sceneModel = require("./sceneMongooseSchema");
const route = express.Router();

route.post("/day_night_cycle", async (req, res)=>{
    try{
        const find_scene = await sceneModel.findOneAndUpdate(
            { scene_name: req.body.scene_name },
            { time: req.body.time },
            { new: true, upsert: true }
        )

        let status = "Failed";
        let scene_name = "Not found";
        let time = 0;

        if(find_scene){
            status = "Success";
            scene_name = find_scene.scene_name;
            time = find_scene.time;
        }

        res.status(200).json({ status: status, scene_name: scene_name, time: time })
    }
    catch(err){
        console.log(err)
    }
});


route.post("/scene_cycle", async (req, res)=>{
    try{
        const find_scene = await sceneModel.findOne({ scene_name: req.body.scene_name })

        let status = "Failed";
        let scene_name = "Not found";
        let time = 0;

        if(find_scene){
            status = "Success";
            scene_name = find_scene.scene_name;
            time = find_scene.time;
        }

        res.status(200).json({ status: status, scene_name: scene_name, time: time })
    }
    catch(err){
        console.log(err)
    }
});

module.exports = route;