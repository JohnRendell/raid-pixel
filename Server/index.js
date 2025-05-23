//Server side
const express = require('express');
const app = express();
const { createServer } = require('http');
const expressServer = createServer(app);
const bodyParser = require('body-parser')

const { WebSocketServer } = require("ws");

//other necessary things such as file path etc
const path = require('path');

//dotenv for the envs
require('dotenv').config({ path: path.resolve(__dirname, '../keys.env') });

//connect to mongodb
const mongoose = require('mongoose');
const uri = process.env.URI;

const clientOptions = { serverApi: { version: '1', strict: true, deprecationErrors: true } };

async function run() {
    try {
        // Create a Mongoose client with a MongoClientOptions object to set the Stable API version
        await mongoose.connect(uri, clientOptions);
        await mongoose.connection.db.admin().command({ ping: 1 });
        console.log("Pinged your deployment. You successfully connected to MongoDB!");
        console.log("Database name: " + mongoose.connection.name)
    }
    catch(err){
        console.log(err)
    }
}
run();

//parse json
app.use(bodyParser.json({limit: '50mb'}));
app.use(bodyParser.urlencoded({limit: '50mb', extended: true}));

//middle ware to serve static files
app.use(express.static(path.join(__dirname, '../Public')));

// Serve the root folder and html
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, '../Public', 'index.html'));
});

//Routers
app.use("/accountRoute", require("./accountRoutes"));
app.use("/gameData", require("./gameDataRoute"));
app.use("/playerInformation", require("./playerInformationRoute"));

//websocket server
const wss = new WebSocketServer({ server: expressServer });

require("./websocket_game_stuff")(wss);
require("./websocket_player_stuff")(wss);

//listen to port
const PORT = process.env.PORT;
expressServer.listen(PORT, async ()=>{
    console.log('Listening to port ' + PORT);
    reset_playerCount(require("./gameDataMongooseSchema"))

    //for scene manager
    const sceneManager = require("./sceneManagerServer")
    await sceneManager.initializeScene();

    sceneManager.startCycle();
});

async function reset_playerCount(gameDataModel){
    try{
        await gameDataModel.findOneAndUpdate(
            {},
            { $set: { playerCount: 0 }},
            { new: true, upsert: true }
        )
    }
    catch(err){
        console.log(err);
    }
}