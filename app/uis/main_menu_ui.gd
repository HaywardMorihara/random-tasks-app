extends Control

@onready var backend_client : BackendClient = $BackendClient;
@onready var get_random_tasks_button : Button = $GetRandomTaskButton
@onready var create_task_button : Button = $CreateTaskButton
@onready var create_task_ui : Control = $CreateTaskUi
@onready var task_stream : Control = $TasksStream



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	create_task_ui.show()
	task_stream.text = await backend_client.get_random_task();


func _on_create_task_ui_task_created() -> void:
	await get_tree().create_timer(2.0).timeout;
	task_stream.text = await backend_client.get_random_task();


func _on_create_task_button_pressed() -> void:
	create_task_ui.show();
