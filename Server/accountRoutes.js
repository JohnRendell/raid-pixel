const express = require("express");
const route = express.Router();
const accountModel = require("./accountMongooseSchema");
const playerInfoModel = require("./playerInformationMongooseSchema");
const sanitize = require("sanitize-html");
const bcrypt = require("bcryptjs")

route.post("/validateAccount", async (req, res)=>{
    try{
        const findAcc = await accountModel.findOne({ username: sanitize(req.body.username) })
        const findPlayerInfo = await playerInfoModel.findOne({ username: sanitize(req.body.username) })

        let status = "Not Found";
        let inGameName = "Not Set";

        if(findAcc && findPlayerInfo){
            let passwordCorrect = await bcrypt.compare(sanitize(req.body.password), findAcc.password)

            if(passwordCorrect){
                status = "Account found"
                inGameName = findPlayerInfo.inGameName
            }
        }
        res.status(200).json({ status: status, inGameName: inGameName });
    }
    catch(err){
        console.log(err);
    }
});

route.post("/createAccount", async (req, res) =>{
    try{
        function hash_pass(pass){
            const salt = bcrypt.genSaltSync(10);
            const hash = bcrypt.hashSync(pass, salt);
            return hash;
        }

        let inGameName = [
            "bob123",
            "hotdogMighty_04",
            "ShadowNoodle",
            "CaptainCrush",
            "PixelPirate",
            "LaserBeard",
            "SneakyPenguin",
            "FunkyFalcon",
            "TacoKnight",
            "ZebraZap",
            "ToastViking",
            "ChocoSlayer",
            "NovaNugget",
            "TurboWaffle",
            "LlamaBlitz",
            "IceCreamSniper",
            "BananaBomber",
            "RoboDuck42",
            "WizardOfLOL",
            "MysticMeatball"
        ];

        const findAcc = await accountModel.findOne({ username: sanitize(req.body.username) });
        let status = ""

        if(findAcc){
            status = "Username already taken!";
        }
        else{
            await accountModel.create({ username: sanitize(req.body.username), password: hash_pass(sanitize(req.body.password)) });
            await playerInfoModel.create({ username: sanitize(req.body.username), inGameName: inGameName[Math.floor(Math.random() * inGameName.length)] })
            status = "Success";
        }
        res.status(200).json({ status: status })
    }
    catch(err){
        console.log(err);
        res.status(500).json({ status: "failed"})
    }
});

module.exports = route;