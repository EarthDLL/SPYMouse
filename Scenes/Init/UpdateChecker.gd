extends Node

var http_request : HTTPRequest

func _ready() -> void:
	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(get_version_info)
	http_request.request("https://earthdll.github.io/spymouse_update.json")
	
func get_version_info(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	print(result)
	print(response_code)
	print(body.get_string_from_utf8())
