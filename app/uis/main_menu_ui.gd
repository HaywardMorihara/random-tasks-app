extends Control

@onready var backend_client : BackendClient = $BackendClient;
@onready var get_random_tasks_button : Button = $GetRandomTaskButton
@onready var create_task_button : Button = $CreateTaskButton
@onready var create_task_ui : Control = $CreateTaskUi
@onready var task_ui : Control = $TaskUi;
@onready var task_stream : Control = $TasksStream


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	create_task_ui.show();
	task_ui.hide();
	_reload_tasks();


func _on_create_task_ui_task_created() -> void:
	_reload_tasks();


func _on_create_task_button_pressed() -> void:
	create_task_ui.show();
	task_ui.hide();

func _on_get_random_task_button_pressed() -> void:
	task_ui.open_random();
	create_task_ui.hide();


func _on_task_ui_task_completed() -> void:
	_reload_tasks();


func _reload_tasks() -> void:
	await get_tree().create_timer(0.5).timeout;
	task_stream.text = JSON.stringify(await backend_client.get_tasks());
