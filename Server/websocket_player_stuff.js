const broadcastSocket = require("./websocket_broadcast");

module.exports = (wss)=>{
    wss.on('connection', (ws) => {
        // Listen for messages from clients
        ws.on('message', async (message) => {
            let parsed_message = JSON.parse(message);
            let socket_name = parsed_message.Socket_Name;
            
            //console.log(parsed_message)

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
        });

        ws.on('error', (err) => {
            console.error(err);
        });
    });
}