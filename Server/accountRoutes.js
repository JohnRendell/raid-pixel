const express = require("express");
const route = express.Router();
const accountModel = require("./accountMongooseSchema");
const sanitize = require("sanitize-html");
const bcrypt = require("bcryptjs")

route.post("/validateAccount", async (req, res)=>{
    try{
        const findAcc = await accountModel.findOne({ username: sanitize(req.body.username) })
        let status = "Not Found";

        if(findAcc){
            let passwordCorrect = await bcrypt.compare(sanitize(req.body.password), findAcc.password)

            if(passwordCorrect){
                status = "Account found"
            }
        }
        res.status(200).json({ status: status });
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

        const findAcc = await accountModel.findOne({ username: sanitize(req.body.username) });
        let status = ""

        if(findAcc){
            status = "Username already taken!";
        }
        else{
            await accountModel.create({ username: sanitize(req.body.username), password: hash_pass(sanitize(req.body.password)) })
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