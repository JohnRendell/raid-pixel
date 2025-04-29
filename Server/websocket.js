module.exports = (server, WebSocketServer)=>{
    // WebSocket server
    const wss = new WebSocketServer({ server });

    wss.on('connection', (ws) => {
        console.log('New client connected');

        // Listen for messages from clients
        ws.on('message', (message) => {
            let parsed_message = JSON.parse(message);
            let socket_name = parsed_message.Socket_Name;
            
            //TODO: Add something here
            console.log(parsed_message)

            if(socket_name === "GlobalMessage"){
                let data = {
                    "Socket_Name": socket_name,
                    "Receiver": parsed_message.Sender,
                    "GameID": parsed_message.GameID,
                    "Message": parsed_message.Message
                }
                broadcastSocket(wss, data);
            }
            /*
            else{
                let data = {
                    "Socket_Name": socket_name,
                    "Player_inGameName": parsed_message.Player_inGameName,
                    "Player_posX": parsed_message.Player_posX,
                    "Player_posY": parsed_message.Player_posY,
                    "isLeft": parsed_message.isLeft,
                    "isRight": parsed_message.isRight,
                    "isDown": parsed_message.isDown,
                    "isUp": parsed_message.isUp
                }
                broadcastSocket(wss, data);
            }
            */

            //TODO: fix this, it wont send back to client.
            // Broadcast message to all clients
            function broadcastSocket(wss, data){
                wss.clients.forEach((client) => {
                    if (client.readyState === WebSocket.OPEN) {
                        console.log(data)
                        client.send(JSON.stringify(data));
                    }
                });
            }
        });

        ws.on('close', () => {
            //TODO: Add something here
        });

        ws.on('error', (err) => {
            console.error(err);
        });
    });
}