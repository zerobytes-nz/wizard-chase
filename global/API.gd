extends Node

signal done_request

#const API_URL := "https://www.theoswap.io/api/public/user-items?apiKey=[Your API key Here]&userCode=%s"
const API_URL := "http://localhost:3080/api/public/user-items?apiKey=[Your API key Here]&userCode=%s"


const TEST_KEYS := ["FlZzuZQl","ZbKv4f","TUdZh8"]

#class Attributes extends Resource:
#	export var key:String
#	export var type:String
#	export var value:String
#	export var data:PoolStringArray
#	pass
#
#class ItemInfo extends Resource:
#	export var itemId:String
#	export var title:String
#	export var attributes:Array
#	pass

var can_request:bool = true
onready var http := HTTPRequest.new()

func _process(delta):
	if Input.is_key_pressed(KEY_F1) and can_request:
		request(TEST_KEYS[0])
		can_request = true
		print("did request....")

func _ready():
	self.pause_mode = PAUSE_MODE_PROCESS
	call_deferred("add_child",http)
#	yield(get_tree().create_timer(1.0),"timeout")
	http.connect("request_completed", self, "on_request_completed")
	

func request(code:String) -> void:

	# Create an HTTP request node and connect its completion signal.

	# Perform a GET request. The URL below returns JSON as of writing.
	var error = http.request(str(API_URL % code))
	print("requested: ", API_URL % code)
	if error != OK:
		push_error("An error occurred in the HTTP request.")
	print("done")
	pass

func on_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray) -> void:
	print("request completed")
	var data = null
	if response_code == 201:
		data = parse_json(body.get_string_from_utf8())
	can_request = true
	emit_signal("done_request", data)
	pass
