module.exports = (server, WebSocketServer)=>{
    // WebSocket server
    const wss = new WebSocketServer({ server });

    wss.on('connection', (ws) => {
        console.log('New client connected');

        // Listen for messages from clients
        ws.on('message', (message) => {
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

        ws.on('close', () => {
            let data = {
                "Socket_Name": "Player_Disconnect",
                "Player_GameID": ws.GameID
            }

            wss.clients.forEach((client) => {
                if (client.readyState === WebSocket.OPEN) {
                    client.send(JSON.stringify(data));
                }
            });
        });

        ws.on('error', (err) => {
            console.error(err);
        });
    });
}