extends Node

var backend_url = "http://localhost:8080/"
var httpRequest: HTTPRequest
var isFetching = false

func _ready() -> void:
	httpRequest = HTTPRequest.new()
	
	if not httpRequest.is_inside_tree():
		add_child(httpRequest)

func send_post_request(route: String, data: Dictionary) -> Dictionary:
	if isFetching:
		return {}
	
	var url = route
	var json_data = JSON.stringify(data)

	var headers = [
		"Content-Type: application/json"
	]
	
	var err = httpRequest.request(url, headers, HTTPClient.METHOD_POST, json_data)
	isFetching = true
	
	if err != OK:
		print("Failed to send request")
		return {}

	# Wait for the request to complete
	var result = await httpRequest.request_completed

	var response_text = result[3].get_string_from_utf8()
	var response_json = JSON.parse_string(response_text)
	isFetching = false

	return response_json

func get_request(route: String) -> Dictionary:
	var url = route

	var headers = [
		"Accept: application/json"
	]

	var err = httpRequest.request(url, headers, HTTPClient.METHOD_GET)
	if err != OK:
		print("Failed to send GET request")
		return {}
		
	# Wait for the request to complete
	var result = await httpRequest.request_completed
	var response_text = result[3].get_string_from_utf8()
	var response_json = JSON.parse_string(response_text)

	return response_json if typeof(response_json) == TYPE_DICTIONARY else {}
