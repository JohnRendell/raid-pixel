const gameDataModel = require("./gameDataMongooseSchema");
const accountModel = require("./accountMongooseSchema");
const playerInfoModel = require("./playerInformationMongooseSchema");
const broadcastSocket = require("./websocket_broadcast");

module.exports = (wss)=>{
    wss.on('connection', (ws) => {
        // Listen for messages from clients
        ws.on('message', async (message) => {
            let parsed_message = JSON.parse(message);
            let socket_name = parsed_message.Socket_Name;

            //for connected player
            if(socket_name === "Player_Connected"){
                broadcastSocket(
                    wss,
                    {
                        "Socket_Name": socket_name,
                        "Player_GameID": parsed_message.Player_GameID,
                    }
                )
                ws.GameID = parsed_message.Player_GameID;
                ws.username = parsed_message.Player_username;

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
                await deleteGuestPlayer_account(parsed_message.Player_username);
                
                ws.GameID = ""
                ws.username = ""

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

            //for player modify profile
            else if(socket_name === "ModifyProfile"){
                broadcastSocket(
                    wss,
                    {
                        "Socket_Name": socket_name,
                        "Player_GameID": parsed_message.Player_GameID,
                        "Player_inGameName": parsed_message.Player_inGameName
                    }
                )
            }
        });

        ws.on('close', async () => {
            if(ws.GameID && ws.username){
                broadcastSocket(
                    wss,
                    {
                       "Socket_Name": "Player_Disconnect",
                        "Player_GameID": ws.GameID
                    }
                )

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

                await deleteGuestPlayer_account(ws.username);
            }
        });

        ws.on('error', (err) => {
            console.error(err);
        });
    });
}

async function deleteGuestPlayer_account(username) {
    try{
        let deleteAcc = await accountModel.findOneAndDelete({ username: username, account_type: "Guest" });

        if(deleteAcc){
            await playerInfoModel.findOneAndDelete({ username: username });
        }
        else{
            await accountModel.findOneAndUpdate({ username: username }, { $set: { isOnline: false }, new: true })
        }
        
    }
    catch(err){
        console.log(err);
    }
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