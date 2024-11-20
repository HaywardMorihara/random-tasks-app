extends Control

@onready var http_requester : HTTPRequest = $HTTPRequest;
@onready var rich_text_label : RichTextLabel = $RichTextLabel;
@onready var text_edit : TextEdit = $TextEdit;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Signals
	http_requester.request_completed.connect(_on_request_completed);
	
	http_requester.request("https://a8hmbfh87l.execute-api.us-east-1.amazonaws.com/tasks/random?user_id=%s" % User.USER_ID);
	
	text_edit.grab_focus();


func _on_request_completed(result, response_code, headers, body):
	var response_string = body.get_string_from_utf8();
	var response_json = JSON.parse_string(response_string);
	
	rich_text_label.text = response_string;
