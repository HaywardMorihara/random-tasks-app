extends Node

const USER_SAVE_FILE_PATH := "user://user.save";

const USER_ID_KEY := "user_id";
const USERNAME_KEY := "username";

var USER_ID : String
var USERNAME : String

func _ready() -> void:
	
	var user : Dictionary = _load_user_from_device();
	
	if user != null and not user.is_empty():
		USER_ID = user["user_id"];
		USERNAME = user["username"];

func _load_user_from_device() -> Dictionary:
	# Note: This can be called from anywhere inside the tree. This function
	# is path independent.
	if not FileAccess.file_exists(USER_SAVE_FILE_PATH):
		print("No user found on the device.");
		return {}

	# Load the file line by line and process that dictionary to restore
	# the object it represents.
	var save_file = FileAccess.open(USER_SAVE_FILE_PATH, FileAccess.READ)
	# Creates the helper class to interact with JSON.
	var json = JSON.new()
	while save_file.get_position() < save_file.get_length():
		var json_string = save_file.get_line()
		# Check if there is any error while parsing the JSON string, skip in case of failure.
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			return {}

	print("Loaded user %s from device" % json.data);

	return json.data


func _save_user_on_device(user : Dictionary) -> void:
	# Note: This can be called from anywhere inside the tree. This function is
	# path independent.
	# Go through everything in the persist category and ask them to return a
	# dict of relevant variables.
	var save_file = FileAccess.open(USER_SAVE_FILE_PATH, FileAccess.WRITE)
	# JSON provides a static method to serialized JSON string.
	var json_string = JSON.stringify(user)
	# Store the save dictionary as a new line in the save file.
	save_file.store_line(json_string)
