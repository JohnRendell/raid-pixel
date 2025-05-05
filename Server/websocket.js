const gameDataModel = require("./gameDataMongooseSchema")

module.exports = (server, WebSocketServer)=>{
    // WebSocket server
    const wss = new WebSocketServer({ server });

    wss.on('connection', (ws) => {
        console.log("Client Connected")

        // Listen for messages from clients
        ws.on('message', async (message) => {
            let parsed_message = JSON.parse(message);
            let socket_name = parsed_message.Socket_Name;
            
            //Global Messages
            if(socket_name == "GlobalMessage"){
                broadcastSocket(
                    wss, 
                    {
                        "Socket_Name": socket_name,
                        "Receiver": parsed_message.Sender,
                        "GameID": parsed_message.GameID,
                        "Message": parsed_message.Message
                    }
                );
            }

            //for connected player
            else if(socket_name === "Player_Connected"){
                broadcastSocket(
                    wss,
                    {
                        "Socket_Name": socket_name,
                        "Player_GameID": parsed_message.Player_GameID
                    }
                )
                ws.GameID = parsed_message.Player_GameID

                let count = await modifyPlayerCount(1)

                if(count["status"] == "Succeed"){
                    broadcastSocket(
                        wss,
                        {
                            "Socket_Name": "PlayerCount",
                            "Count": count["playerCount"]
                        }
                    )
                }

                ws.send(JSON.stringify(
                    {
                        "Socket_Name": socket_name,
                        "Player_GameID": parsed_message.Player_GameID
                    }
                ));
            }

            //for player logout
            else if(socket_name === "Player_Logout"){
                broadcastSocket(
                    wss,
                    {
                        "Socket_Name": "Player_Disconnect",
                        "Player_GameID": parsed_message.GameID
                    }
                )
                ws.GameID = ""

                let count = await modifyPlayerCount(-1)

                if(count["status"] == "Succeed"){
                    broadcastSocket(
                        wss,
                        {
                            "Socket_Name": "PlayerCount",
                            "Count": count["playerCount"]
                        }
                    )
                }
            }
           
            //for spawn players
            else if(socket_name === "Player_Spawn"){
                broadcastSocket(
                    wss,
                    {
                        "Socket_Name": socket_name,
                        "Player_inGameName": parsed_message.Player_inGameName,
                        "Player_GameID": parsed_message.Player_GameID,
                        "Player_posX": parsed_message.Player_posX,
                        "Player_posY": parsed_message.Player_posY,
                        "isLeft": parsed_message.isLeft,
                        "isRight": parsed_message.isRight,
                        "isDown": parsed_message.isDown,
                        "isUp": parsed_message.isUp,
                        "player_type": parsed_message.player_type,
                        "isAttacking": parsed_message.isAttacking
                    }
                )
            }

            // Broadcast message to all clients
            function broadcastSocket(wss, data){
                wss.clients.forEach((client) => {
                    if (client.readyState === WebSocket.OPEN) {
                        client.send(JSON.stringify(data));
                    }
                });
            }
        });

        ws.on('close', async () => {
            if(ws.GameID){
                let data = {
                    "Socket_Name": "Player_Disconnect",
                    "Player_GameID": ws.GameID
                }

                wss.clients.forEach((client) => {
                    if (client.readyState === WebSocket.OPEN) {
                        client.send(JSON.stringify(data));
                    }
                });

                let count = await modifyPlayerCount(-1)

                if(count["status"] == "Succeed"){
                    let countData =
                        {
                            "Socket_Name": "PlayerCount",
                            "Count": count["playerCount"]
                        }

                    wss.clients.forEach((client) => {
                        if (client.readyState === WebSocket.OPEN) {
                            client.send(JSON.stringify(countData));
                        }
                    });
                }
            }
        });

        ws.on('error', (err) => {
            console.error(err);
        });
    });
}

async function modifyPlayerCount(count){
    try{
        let status = "Failed"
        let playerCount = 0

        await gameDataModel.findOneAndUpdate(
            {}, 
            { $inc: { playerCount: count }},
            { new: true, upsert: true }
        );

        //clamp to zero when it become negative
        await gameDataModel.findOneAndUpdate(
            {}, 
            { $max: { playerCount: 0 }},
            { new: true }
        );

        const updatePlayerCount = await gameDataModel.findOne({});

        if(updatePlayerCount){
            status = "Succeed";
            playerCount = updatePlayerCount.playerCount
        }

        return {
            status: status,
            playerCount: playerCount
        }
    }
    catch(err){
        console.log(err)
    }
}