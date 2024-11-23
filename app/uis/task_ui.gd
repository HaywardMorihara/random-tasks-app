extends Panel

signal task_completed;

@onready var backend_client : BackendClient = $BackendClient;

@onready var task_label : RichTextLabel = $TaskLabel;
@onready var close_button : Button = $CloseButton;
@onready var status_label : RichTextLabel = $StatusLabel;
@onready var complete_button : Button = $CompleteButton;

var task_id : String;


func open_random() -> void:
	show();
	var task_data = await backend_client.get_random_task();
	task_id = task_data.id;
	task_label.text = task_data.label;
	status_label.text = task_data.status;
	complete_button.disabled = task_data.status == "COMPLETED";


func _on_close_button_pressed() -> void:
	_hide_self();


func _on_complete_button_pressed() -> void:
	backend_client.complete_task(task_id);
	task_completed.emit();
	_hide_self();


func _hide_self() -> void:
	hide();
	task_id = "";
	task_label.text = "";
	status_label.text = "";
