extends Control

signal task_created

@onready var backend_client : BackendClient = $BackendClient
@onready var task_label_text_edit : TextEdit = $TaskLabelTextEdit

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	task_label_text_edit.grab_focus();


func _on_create_button_pressed() -> void:
	backend_client.create_task(task_label_text_edit.text);
	task_created.emit();
	hide();
	task_label_text_edit.text = "";


func _on_close_button_pressed() -> void:
	hide();
	task_label_text_edit.text = "";
