//Server side
const express = require('express');
const app = express();
const { createServer } = require('http');
const expressServer = createServer(app);

const { WebSocketServer } = require("ws");

//other necessary things such as file path etc
const path = require('path');


//middle ware to serve static files
app.use(express.static(path.join(__dirname, '../Public')));

// Serve the root folder and html
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, '../Public', 'index.html'));
});

//Routers


//websockets
require("./websocket")(expressServer, WebSocketServer)

//listen to port
require('dotenv').config({ path: path.resolve(__dirname, '../keys.env') });

const PORT = process.env.PORT;
expressServer.listen(PORT, ()=>{
    console.log('Listening to port ' + PORT);
});