extends Control

@onready var backend_client : BackendClient = $BackendClient;
@onready var get_random_tasks_button : Button = $GetRandomTaskButton
@onready var create_task_button : Button = $CreateTaskButton
@onready var create_task_ui : Control = $CreateTaskUi
@onready var task_ui : Control = $TaskUi;
@onready var all_tasks_list : ItemList = $AllTasksList


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


func _on_task_ui_task_edited() -> void:
	_reload_tasks();


func _on_all_tasks_list_item_selected(index: int) -> void:
	var selected_task_data = all_tasks_list.get_item_metadata(index);
	task_ui.open(selected_task_data.id);
	create_task_ui.hide();


func _reload_tasks() -> void:
	await get_tree().create_timer(0.5).timeout; # To give time for the submission to be processed
	all_tasks_list.clear();
	var all_tasks_response : Array = await backend_client.get_tasks();
	for task in all_tasks_response:
		all_tasks_list.add_item(task.label);
		all_tasks_list.set_item_metadata(all_tasks_list.item_count - 1, task);
