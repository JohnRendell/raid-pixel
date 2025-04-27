extends Node

#NOTE: this whole script is from official godot docs that i tweaked -> me for future me.

# The URL we will connect to.
@export var websocket_url = "ws://localhost:8080"

# Our WebSocketClient instance.
var socket = WebSocketPeer.new()

# for sending data to backend
var socket_data: JSON

#connection status
var socket_connection_status: String

func _ready():
	established_connection()

func _process(_delta):
	# Call this in _process or _physics_process. Data transfer and state updates
	# will only happen when calling this function.
	socket.poll()

	# get_ready_state() tells you what state the socket is in.
	var state = socket.get_ready_state()
	
	match state:
		# WebSocketPeer.STATE_OPEN means the socket is connected and ready
		# to send and receive data.
		WebSocketPeer.STATE_OPEN:
			socket_connection_status = "Connected";
			
			while socket.get_available_packet_count() > 0:
				var raw = socket.get_packet().get_string_from_utf8()
				socket_data = JSON.parse_string(raw)
			
		#for connecting
		WebSocketPeer.STATE_CONNECTING:
			socket_connection_status = "Connecting to server";

		# WebSocketPeer.STATE_CLOSING means the socket is closing.
		# It is important to keep polling for a clean close.
		WebSocketPeer.STATE_CLOSING:
			socket_connection_status = "Closing"

		# WebSocketPeer.STATE_CLOSED means the connection has fully closed.
		# It is now safe to stop polling.
		WebSocketPeer.STATE_CLOSED:
			socket_connection_status = "Disconnected";
			
			# The code will be -1 if the disconnection was not properly notified by the remote peer.
			var code = socket.get_close_code()
			print("WebSocket closed with code: %d. Clean: %s" % [code, code != -1])
			set_process(false) # Stop processing.
	
func established_connection():
	# Initiate connection to the given URL.
	var err = socket.connect_to_url(websocket_url)
	
	if err != OK:
		print("Unable to connect")
		set_process(false)
	else:
		# Wait for the socket to connect.
		await get_tree().create_timer(2).timeout
		set_process(true)

func retry_connection():
	socket_connection_status = "Reconnecting"
	
	await get_tree().create_timer(1.0).timeout
	established_connection()
