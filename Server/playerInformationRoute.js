const express = require("express");
const route = express.Router();
const playerInfoModel = require("./playerInformationMongooseSchema");

route.post("/playerData", async (req, res)=>{
    try{
        const findData = await playerInfoModel.findOne({ username: req.body.username });
        let status = "Failed";
        let diamond = 0;
        let profile = "Invalid";
        let inGameName = "Not Found";
        let description = "Not Found"

        if(findData){
            status = "Success";
            diamond = findData.diamond;
            profile = findData.profile;
            inGameName = findData.inGameName;
            description = findData.description;
        }

        res.status(200).json({ status: status, diamond: diamond, profile: profile, inGameName: inGameName, description: description });
    }
    catch(err){
        console.log(err)
    }
});

module.exports = route