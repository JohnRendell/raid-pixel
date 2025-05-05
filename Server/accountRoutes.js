const express = require("express");
const route = express.Router();
const accountModel = require("./accountMongooseSchema");
const playerInfoModel = require("./playerInformationMongooseSchema");
const sanitize = require("sanitize-html");
const bcrypt = require("bcryptjs")
const { v4: uuidv4 } = require('uuid');

route.post("/validateAccount", async (req, res)=>{
    try{
        const findAcc = await accountModel.findOne({ username: sanitize(req.body.username) })
        const findPlayerInfo = await playerInfoModel.findOne({ username: sanitize(req.body.username) })

        let status = "Not Found";
        let inGameName = "Not Set";
        let diamond = 0;
        let username = "Not found";
        let login_token = "Not found";
        let player_account_type = "Not found";
        let player_profile = "Not found";

        if(findAcc && findPlayerInfo){
            let passwordCorrect = await bcrypt.compare(sanitize(req.body.password), findAcc.password)

            if(passwordCorrect){
                status = "Account found"
                inGameName = findPlayerInfo.inGameName;
                diamond = findPlayerInfo.diamond;
                username = findPlayerInfo.username;
                login_token = findAcc.login_token;
                player_account_type = findAcc.account_type;
                player_profile = findPlayerInfo.profile
            }
        }
        res.status(200).json({ status: status, inGameName: inGameName, playerDiamond: diamond, username: username, login_token: login_token, player_type: player_account_type, player_profile: player_profile });
    }
    catch(err){
        console.log(err);
    }
});

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

route.post("/connectAccount", async (req, res)=>{
    try{
        const findAcc = await accountModel.findOneAndUpdate(
            { username: sanitize(req.body.username) },
            { $set: { password: hash_pass(req.body.password), account_type: "Player" } },
            { new: true }
        )

        let status = "Not Found";
        let account_type = "Guest";

        if(findAcc){
            status = "Success";
            account_type = findAcc.account_type;
        }
        res.status(200).json({ status: status, accountType: account_type });
    }
    catch(err){
        console.log(err);
    }
});

route.post("/createAccount", async (req, res) =>{
    try{
        const findAcc = await accountModel.findOne({ username: sanitize(req.body.username) });
        let status = ""

        if(findAcc){
            status = "Username already taken!";
        }
        else{
            await accountModel.create({ username: sanitize(req.body.username), password: hash_pass(sanitize(req.body.password)), account_type: "Player", login_token: uuidv4() });
           
            await playerInfoModel.create({ username: sanitize(req.body.username), inGameName: inGameName[Math.floor(Math.random() * inGameName.length)], diamond: 1000, profile: "https://i.imgur.com/ajVzRmV.png", description: "No description yet" })
            status = "Success";
        }
        res.status(200).json({ status: status })
    }
    catch(err){
        console.log(err);
        res.status(500).json({ status: "failed"})
    }
});

route.post("/createGuestAccount", async (req, res)=>{
    try{
        function generatePassword() {
            var length = 8,
                charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789",
                retVal = "";
            for (var i = 0, n = charset.length; i < length; ++i) {
                retVal += charset.charAt(Math.floor(Math.random() * n));
            }
            return retVal;
        }

        const createAcc = await accountModel.create({ username: sanitize(req.body.username), password: hash_pass(generatePassword()), account_type: "Guest", login_token: uuidv4() });
        
        const playerInfo = await playerInfoModel.create({ username: sanitize(req.body.username), inGameName: inGameName[Math.floor(Math.random() * inGameName.length)], diamond: 1000, profile: "https://i.imgur.com/ajVzRmV.png", description: "No description yet" })
        
        let status = "failed";
        let diamond = 0;
        let username = "Not Found";
        let gameUser = "Not Found";
        let login_token = "Not Found";
        let player_account_type = "Not Found";
        let player_profile = "Not Found";

        if(createAcc && playerInfo){
            status = "Success";
            username = playerInfo.username;
            gameUser = playerInfo.inGameName;
            diamond = playerInfo.diamond;
            login_token = createAcc.login_token;
            player_account_type = createAcc.account_type;
            player_profile = playerInfo.profile
        }
        res.status(200).json({ status: status, username: username, diamond: diamond, inGameName: gameUser, login_token: login_token, player_type: player_account_type, player_profile: player_profile })
    }
    catch(err){
        console.log(err);
        res.status(500).json({ status: "failed"})
    }
});

route.post("/auth_auto_login", async (req, res)=>{
    try{
        let login_token = req.body.login_token;
        let status = "Failed";

        let username = "Not found";
        let diamond = 0;
        let gameName = "Not Found";
        let player_account_type = "Not Found";
        let UUID = "Not Found";
        let player_profile = "No Found";

        const findUser = await accountModel.findOne({ username: req.body.username, login_token: login_token });
        const findPlayerInfo = await playerInfoModel.findOne({ username: req.body.username })

        if(findUser && findPlayerInfo){
            status = "Success";
            username = findUser.username;
            diamond = findPlayerInfo.diamond;
            gameName = findPlayerInfo.inGameName;
            player_account_type = findUser.account_type;
            UUID = findUser.login_token;
            player_profile = findPlayerInfo.profile
        }
        else{
            const findUser = await accountModel.findOne({ username: req.body.username });
            const findPlayerInfo = await playerInfoModel.findOne({ username: req.body.username })

            if(findUser && findUser.account_type == "Guest" && findPlayerInfo){
                await accountModel.findOneAndDelete({ username: findUser.username });
                await playerInfoModel.findOneAndDelete({ username: findPlayerInfo.username })
                status = "Modified account on guest side, deleting....";
            }
        }

        res.status(200).json({ status: status, username: username, playerDiamond: diamond, inGameName: gameName, player_type: player_account_type, UUID: UUID, player_profile: player_profile })
    }
    catch(err){
        console.log(err);
    }
});

route.post("/deleteAccountGuest", async (req, res)=>{
    try{
        let status = "Failed";
        let login_token = req.body.login_token;

        const findUser = await accountModel.findOneAndDelete({ username: req.body.username, login_token: login_token, account_type: "Guest" });
        const findPlayerInfo = await playerInfoModel.findOneAndDelete({ username: req.body.username })

        if(findUser && findPlayerInfo){
            status = "Success";
        }

        res.status(200).json({ status: status })
    }
    catch(err){
        console.log(err);
    }
});

module.exports = route;