const express = require("express");
const route = express.Router();
const playerInfoModel = require("./playerInformationMongooseSchema");
const sanitizeHTML = require("sanitize-html")

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

route.post("/modifyPlayerData", async (req, res)=>{
    try{
        const rawDescription = req.body.description || "";
        const cleanDescription = rawDescription.trim() === "" ? "No Description yet." : rawDescription;

        const findData = await playerInfoModel.findOneAndUpdate(
            { username: req.body.username },
            { $set: { inGameName: sanitizeHTML(req.body.inGameName), description: sanitizeHTML(cleanDescription) }},
            { new: true }
        );
        let status = "Failed";
        let inGameName = "Not Found";
        let description = "Not Found"

        if(findData){
            status = "Success";
            inGameName = findData.inGameName;
            description = findData.description;
        }

        res.status(200).json({ status: status, inGameName: inGameName, description: description });
    }
    catch(err){
        console.log(err)
    }
});

module.exports = route