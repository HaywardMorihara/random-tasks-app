class_name BackendClient extends HTTPRequest

const DOMAIN = "https://a8hmbfh87l.execute-api.us-east-1.amazonaws.com"

var response_json : Variant 


func _ready() -> void:
	# Signals
	self.request_completed.connect(_on_request_completed);	


func get_random_task() -> String:
	request("%s/tasks/random?user_id=%s" % [DOMAIN, User.USER_ID]);
	await request_completed;
	return JSON.stringify(response_json);


func create_task(label : String) -> void:
	var json = JSON.stringify({
		"label": label,
	});
	var headers = ["Content-Type: application/json"]
	request(_build_request_url("/tasks"), headers, HTTPClient.METHOD_POST, json)


func _build_request_url(path : String) -> String:
	return "%s%s?user_id=%s" % [DOMAIN, path, User.USER_ID]


func _on_request_completed(result, response_code, headers, body):
	var response_string = body.get_string_from_utf8();
	response_json = JSON.parse_string(response_string);
	print(response_json)
