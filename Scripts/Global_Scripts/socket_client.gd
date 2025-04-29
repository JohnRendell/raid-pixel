extends Node

var socket = WebsocketsConnection.socket
var socket_data = WebsocketsConnection.socket_data

func send_data(data):
	if socket.get_ready_state() == WebSocketPeer.STATE_OPEN:
		var json_string = JSON.stringify(data)
		socket.send_text(json_string)
