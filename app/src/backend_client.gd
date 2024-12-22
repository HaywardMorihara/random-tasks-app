class_name BackendClient extends HTTPRequest


var domain : String
var response_json : Variant 


func _ready() -> void:
	domain = Export.DOMAIN;
	
	# Signals
	self.request_completed.connect(_on_request_completed);	


func create_task(label : String, weight : float) -> void:
	var json = JSON.stringify({
		"label": label,
		"weight": weight,
	});
	var headers = ["Content-Type: application/json"]
	request(_build_request_url("/tasks"), headers, HTTPClient.METHOD_POST, json)


func get_task(task_id : String) -> Dictionary:
	request(_build_request_url("/tasks/%s" % task_id));
	await request_completed;
	return response_json;


func get_random_task() -> Dictionary:
	request(_build_request_url("/tasks/random"));
	await request_completed;
	return response_json;


func get_tasks() -> Array:
	request(_build_request_url("/tasks"));
	await request_completed;
	return response_json;


func complete_task(task_id : String) -> void:
	var json = JSON.stringify({
		"status": "COMPLETED",
	});
	var headers = ["Content-Type: application/json"];
	request(_build_request_url("/tasks/%s" % task_id), headers, HTTPClient.METHOD_PATCH, json);


func edit_task(task_id : String, edited_task_data : Dictionary) -> void:
	var json = JSON.stringify(edited_task_data);
	var headers = ["Content-Type: application/json"];
	request(_build_request_url("/tasks/%s" % task_id), headers, HTTPClient.METHOD_PATCH, json);


func _build_request_url(path : String) -> String:
	return "%s%s?user_id=%s" % [domain, path, User.USER_ID]


func _on_request_completed(result, response_code, headers, body):
	var response_string = body.get_string_from_utf8();
	response_json = JSON.parse_string(response_string);
	print(response_json)
