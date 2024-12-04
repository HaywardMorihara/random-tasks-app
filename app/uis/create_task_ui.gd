extends Control

signal task_created
signal create_task_ui_closed;

@onready var backend_client : BackendClient = $BackendClient;
@onready var task_label_text_edit : TextEdit = $TaskLabelTextEdit;
@onready var task_weight_edit : SpinBox = $WeightEdit;

func _ready() -> void:
	task_label_text_edit.grab_focus();


func _on_create_button_pressed() -> void:
	backend_client.create_task(task_label_text_edit.text, task_weight_edit.value);
	task_created.emit();
	hide();
	_reset();


func _on_close_button_pressed() -> void:
	create_task_ui_closed.emit();
	hide();
	_reset();


func _on_visibility_changed() -> void:
	if is_visible_in_tree() and task_label_text_edit:
		task_label_text_edit.grab_focus();


func _reset() -> void:
	task_label_text_edit.text = "";
	task_weight_edit.value = 1.0;
