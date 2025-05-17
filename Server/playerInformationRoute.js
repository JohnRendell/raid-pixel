const express = require("express");
const route = express.Router();
const playerInfoModel = require("./playerInformationMongooseSchema");
const sanitizeHTML = require("sanitize-html")
const fetch = (...args) => import('node-fetch').then(({default: fetch}) => fetch(...args));

require("dotenv").config({ path: require("path").resolve(__dirname, "../keys.env")})


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

async function upload_image_imgur(profile){
    try{
        if(profile){
            const uploadImage = await fetch("https://api.imgur.com/3/image", {
                method: "POST",
                headers: {
                    Authorization: `Bearer ${process.env.IMGUR_ACCESS_TOKEN}`,
                    "Content-Type": "application/json" 
                },
                body: JSON.stringify({ image: profile,  album: "BkaAHPo" })
            })
    
            const uploadImage_res = await uploadImage.json();
    
            if(uploadImage_res.success){
                return uploadImage_res.data
            } 
            else {
                console.error("Upload Failed:", uploadImage_res);
                return null;
            }
        }
    }
    catch(err){
        console.log(err);
    }
}

route.post("/modifyPlayerData", async (req, res)=>{
    try{
        const rawDescription = req.body.description || "";
        const cleanDescription = rawDescription.trim() === "" ? "No Description yet." : rawDescription;

        const update_fields = {
            inGameName: sanitizeHTML(req.body.inGameName),
            description: sanitizeHTML(cleanDescription)
        }

        if(req.body.profile){
            let wait_for_upload = await upload_image_imgur(req.body.profile)

            if(wait_for_upload){
                update_fields.profile = wait_for_upload.link;
                update_fields.profile_hash = wait_for_upload.id
            }
        }

        const findData = await playerInfoModel.findOneAndUpdate(
            { username: req.body.username },
            { $set: update_fields },
            { new: true }
        );
        let status = "Failed";
        let inGameName = "Not Found";
        let description = "Not Found";
        let profile = ""

        if(findData){
            status = "Success";
            inGameName = findData.inGameName;
            description = findData.description;
            profile = findData.profile;
        }

        res.status(200).json({ status: status, inGameName: inGameName, description: description, profile: profile });
    }
    catch(err){
        console.log(err)
    }
});

module.exports = route