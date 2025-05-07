extends Node

var socket = WebsocketsConnection.socket
var socket_data = WebsocketsConnection.socket_data

var connection_status = ""

func _process(_delta: float) -> void:
	if PlayerGlobalScript.player_game_id and connection_status !=  WebsocketsConnection.socket_connection_status:
		send_data(
			{
				"Socket_Name": "Player_Connected" if WebsocketsConnection.socket_connection_status == "Connected" else "Player_Disonnected",
				"Player_GameID": PlayerGlobalScript.player_game_id,
				"Player_username": PlayerGlobalScript.player_username,
			}
		)
		
		connection_status = WebsocketsConnection.socket_connection_status

func send_data(data):
	if socket.get_ready_state() == WebSocketPeer.STATE_OPEN:
		var json_string = JSON.stringify(data)
		socket.send_text(json_string)
		
func received_data():
	if socket.get_ready_state() == WebSocketPeer.STATE_OPEN:
		while socket.get_available_packet_count() > 0:
			var raw = socket.get_packet().get_string_from_utf8()
			socket_data = JSON.parse_string(raw)

		return socket_data
