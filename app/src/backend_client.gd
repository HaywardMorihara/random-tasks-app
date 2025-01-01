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


# This gets called by User.gd - I don't love the ciruclar dependency that risks (building the ?user_id=User.USER_ID query param)
func user_sign_in(username : String) -> Dictionary:
	var json = JSON.stringify({
		"username": username,
	});
	var headers = ["Content-Type: application/json"];
	var error = request(_build_request_url_no_user("/users/signin"), headers, HTTPClient.METHOD_POST, json);
	if error != OK:
		print("ERROR: Signing the user in: %s" % error)
		return {};
	await request_completed;
	return {
		"user_id": _extract_user_id(response_json["pk"]),
		"username": response_json["username"],
	}


func _build_request_url(path : String) -> String:
	var url := "%s%s?user_id=%s" % [domain, path, User.USER_ID]
	print("Making request to URL: %s" % url)
	return url

func _build_request_url_no_user(path : String) -> String:
	return "%s%s" % [domain, path]

func _extract_user_id(pk : String) -> String:
	var parts = pk.split("#")
	if parts.size() != 2:
		print("ERROR: Invalid PK format: %s" % pk)
		return ""
	return parts[1];

func _on_request_completed(result, response_code, headers, body):
	var response_string = body.get_string_from_utf8();
	response_json = JSON.parse_string(response_string);
	print(response_json)
