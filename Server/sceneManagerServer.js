const sceneModel = require("./sceneMongooseSchema");

//scenes
let scenes = [
    { scene_name: "lobby", max_time: 300 },
    { scene_name: "Map Scene", max_time: 20 }
]

async function initializeScene(){
    for(const scene of scenes){
        try{
            const getScene_time = await sceneModel.findOne({ scene_name: scene.scene_name });

            if(!getScene_time){
                await sceneModel.findOneAndUpdate(
                    { scene_name: scene.scene_name },
                    { $set: { time: 0, time_max: scene.max_time }},
                    { new: true, upsert: true }
                )
            }
        }
        catch(err){
            console.log(err)
        }
    }
}

async function play_day_night_cycle(){
    for(const scene of scenes){
        try{
            let findScene = await sceneModel.findOne({ scene_name: scene.scene_name })

            if(findScene){
                const newTime = (findScene.time + 1) % scene.max_time;

                await sceneModel.findOneAndUpdate(
                    { scene_name: scene.scene_name },
                    { $set: { time: newTime }},
                    { new: true }
                )
            }
        }
        catch(err){
            console.log(err)
        }
    }
}

async function startCycle() {
    setInterval(play_day_night_cycle, 1000)
}

module.exports = {
    initializeScene,
    startCycle
}