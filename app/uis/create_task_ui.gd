extends Control

signal task_created

@onready var backend_client : BackendClient = $BackendClient
@onready var task_label_text_edit : TextEdit = $TaskLabelTextEdit

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


func _on_visibility_changed() -> void:
	if is_visible_in_tree() and task_label_text_edit:
		task_label_text_edit.grab_focus();
