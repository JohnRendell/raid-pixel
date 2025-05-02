extends Node

var socket = WebsocketsConnection.socket
var socket_data = WebsocketsConnection.socket_data
var isConnected = false

func _process(_delta: float) -> void:
	if PlayerGlobalScript.player_game_id and WebsocketsConnection.socket_connection_status == "Connected" and not isConnected:
		send_data(
			{
				"Socket_Name": "Player_Connected",
				"Player_GameID": PlayerGlobalScript.player_game_id
			}
		)
		isConnected = true
		
	elif WebsocketsConnection.socket_connection_status == "Disconnected":
		send_data(
			{
				"Socket_Name": "Player_Disonnected",
				"Player_GameID": PlayerGlobalScript.player_game_id
			}
		)
		isConnected = false

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
