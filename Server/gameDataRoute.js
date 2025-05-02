const express = require("express");
const gameDataModel = require("./gameDataMongooseSchema");
const route = express.Router();

//TODO: repurpose this one in the future
route.post("/", async (req, res)=>{
    try{
        console.log("Repurpose this one bruh")
    }
    catch(err){
        console.log(err)
    }
});

module.exports = route;