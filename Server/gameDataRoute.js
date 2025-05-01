const express = require("express");
const gameDataModel = require("./gameDataMongooseSchema");
const route = express.Router();

route.post("/modifyPlayerCount", async (req, res)=>{
    try{
        let status = "Failed"
        let playerCount = 0

        const updatePlayerCount = await gameDataModel.findOneAndUpdate(
            {}, 
            { $inc: { playerCount: req.body.playerCount }},
            { new: true, upsert: true }
        );

        if(updatePlayerCount){
            //TODO: fix the player count
            /*
            if(updatePlayerCount.playerCount < 0){
                updatePlayerCount = await gameDataModel.findOneAndUpdate(
                    {}, 
                    { $set: { playerCount: 0 }},
                    { new: true, upsert: true }
                );
            }*/
            status = "Succeed";
            playerCount = updatePlayerCount.playerCount
        }
        res.status(200).json({ status: status, playerCount: playerCount })
    }
    catch(err){
        console.log(err)
    }
});

module.exports = route;