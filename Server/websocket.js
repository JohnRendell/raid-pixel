module.exports = (server, WebSocketServer)=>{
    // WebSocket server
    const wss = new WebSocketServer({ server });

    wss.on('connection', (ws) => {
        console.log('New client connected');

        // Listen for messages from clients
        ws.on('message', (message) => {
            //TODO: Add something here

            // Broadcast message to all clients
            wss.clients.forEach((client) => {
                if (client.readyState === ws.OPEN) {
                    //TODO: Add something here
                }
            });
        });

        ws.on('close', () => {
            //TODO: Add something here
        });

        ws.on('error', (err) => {
            console.error(err);
        });
    });
}