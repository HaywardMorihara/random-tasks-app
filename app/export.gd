extends Node

const CONFIG_FILE_PATH := "res://export.cfg"
const CONFIG_FILE_SECTION_SECRETS := "secrets"
const CONFIG_FILE_SECRET_KEY_SECRET_API_URL := "api_url"
const CONFIG_FILE_SECRET_DEFAULT_API_URL := ""

var DOMAIN : String

func _ready() -> void:
	var config = ConfigFile.new();
	var err = config.load(CONFIG_FILE_PATH);
	if err == OK:
		DOMAIN = config.get_value(CONFIG_FILE_SECTION_SECRETS, CONFIG_FILE_SECRET_KEY_SECRET_API_URL, CONFIG_FILE_SECRET_DEFAULT_API_URL);
		print("API URL: ", DOMAIN);
	else:
		print("Failed to load config file: ", err);
