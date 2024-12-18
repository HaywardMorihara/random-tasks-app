extends Panel

signal edit_task_ui_closed;
signal task_completed;
signal task_edited;

@onready var backend_client : BackendClient = $BackendClient;

@onready var close_button : Button = $CloseButton;
@onready var task_label : TextEdit = $TaskLabel;
@onready var task_weight : SpinBox = $Weight;
@onready var status_label : RichTextLabel = $StatusLabel;
@onready var complete_button : Button = $CompleteButton;
@onready var save_button : Button = $SaveButton;

var default_label : String;
var default_status : String;
var default_weight : float = 1.0;

var task_id : String;


func _ready() -> void:
	default_label = task_label.text;
	default_status = status_label.text;


func open(task_id : String) -> void:
	show();
	var task_data = await backend_client.get_task(task_id);
	_set_task(task_data);


func open_random() -> void:
	show();
	var task_data = await backend_client.get_random_task();
	_set_task(task_data);


func _on_close_button_pressed() -> void:
	_hide_self();
	edit_task_ui_closed.emit();


func _on_complete_button_pressed() -> void:
	backend_client.complete_task(task_id);
	task_completed.emit();
	_hide_self();


func _on_save_button_pressed() -> void:
	# TODO Only send what changed
	var task_data = {
		"label": task_label.text,
		"weight": task_weight.value,
	}
	backend_client.edit_task(task_id, task_data);
	task_edited.emit();
	_hide_self();


func _hide_self() -> void:
	hide();
	task_id = "";
	task_label.text = default_label;
	status_label.text = default_status;


# TODO Make a 'Task' class
func _set_task(task_data : Variant) -> void:
	task_id = task_data.id;
	task_label.text = task_data.label;
	if task_data.has("weight"):
		task_weight.value = task_data.weight;
	else:
		task_weight.value = default_weight;
	status_label.text = task_data.status;
	complete_button.disabled = task_data.status == "COMPLETED";
