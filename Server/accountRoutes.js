const express = require("express");
const route = express.Router();
const accountModel = require("./accountMongooseSchema");
const playerInfoModel = require("./playerInformationMongooseSchema");
const sanitize = require("sanitize-html");
const bcrypt = require("bcryptjs")
const { v4: uuidv4 } = require('uuid');

async function setOnline(username){
    try{
        await accountModel.findOneAndUpdate({ username: username }, { $set: { isOnline: true }}, { new: true })
    }
    catch(err){
        console.log(err)
    }
}

route.post("/validateAccount", async (req, res)=>{
    try{
        const findAcc = await accountModel.findOne({ username: sanitize(req.body.username) })

        let status = "Not Found";
        let username = "Not found";
        let login_token = "Not found";
        let player_account_type = "Not found";
        let isOnline = false

        if(findAcc){
            let passwordCorrect = await bcrypt.compare(sanitize(req.body.password), findAcc.password)

            if(passwordCorrect){
                status = "Account found"
                username = findAcc.username;
                login_token = findAcc.login_token;
                player_account_type = findAcc.account_type;
                isOnline = findAcc.isOnline

                if(!isOnline){
                    setOnline(username)
                }
            }
        }
        res.status(200).json({ status: status, username: username, login_token: login_token, player_type: player_account_type, isOnline: isOnline });
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
            await accountModel.create({ username: sanitize(req.body.username), password: hash_pass(sanitize(req.body.password)), account_type: "Player", login_token: uuidv4(), isOnline: true });
           
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

        const createAcc = await accountModel.create({ username: sanitize(req.body.username), password: hash_pass(generatePassword()), account_type: "Guest", login_token: uuidv4(), isOnline: true });
        
        let status = "failed";
        let username = "Not Found";
        let login_token = "Not Found";
        let player_account_type = "Not Found";

        if(createAcc){
            status = "Success";
            username = createAcc.username;
            login_token = createAcc.login_token;
            player_account_type = createAcc.account_type;

            await playerInfoModel.create({ username: sanitize(req.body.username), inGameName: inGameName[Math.floor(Math.random() * inGameName.length)], diamond: 1000, profile: "https://i.imgur.com/ajVzRmV.png", description: "No description yet" })
        }
        res.status(200).json({ status: status, username: username, login_token: login_token, player_type: player_account_type })
    }
    catch(err){
        console.log(err);
        res.status(500).json({ status: "failed"})
    }
});

let first_come_first_serve = []

route.post("/auth_auto_login", async (req, res)=>{
    try{
        let login_token = req.body.login_token;
        let status = "Failed";

        let username = "Not found";
        let player_account_type = "Not Found";
        let UUID = "Not Found";
        let client_token_result = { client_result: "Failed" }

        let data_obj = req.body.client_token
        first_come_first_serve.push(data_obj)

        const filterUser = first_come_first_serve.filter(data => data.username === data_obj.username)
        let token_status = filterUser.length == 1 ? "Accepted" : "Rejected";

        client_token_result = { username: data_obj.username, token: data_obj.token, status: token_status }

        const tokenToRemove = data_obj.token;
        setTimeout(() => {
            const index = first_come_first_serve.findIndex(t => t.token === tokenToRemove);
            if (index >= 0) first_come_first_serve.splice(index, 1);
        }, 5000);

        const findUser = await accountModel.findOne({ username: req.body.username, login_token: login_token });

        if(findUser){
            status = "Success";
            username = findUser.username;
            player_account_type = findUser.account_type;
            UUID = findUser.login_token;
            client_token_result = client_token_result;

            if(client_token_result.status == "Accepted"){
                setOnline(username)
            }
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

        res.status(200).json({ status: status, username: username, player_type: player_account_type, UUID: UUID, client_token_result: client_token_result })
    }
    catch(err){
        console.log(err);
    }
});

module.exports = route;