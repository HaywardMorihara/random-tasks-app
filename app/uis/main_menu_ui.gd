extends Control

const USER_LABEL_TEXT = "Hello %s"

@onready var backend_client : BackendClient = $BackendClient;
@onready var get_random_tasks_button : Button = $GetRandomTaskButton;
@onready var create_task_button : Button = $CreateTaskButton;
@onready var create_task_ui : Control = $CreateTaskUi;
@onready var edit_task_ui : Control = $EditTaskUi;
@onready var all_tasks_list : ItemList = $AllTasksList;
@onready var user_label : Label = $UserLabel;

# State
var task_list_has_been_loaded_first_time : bool = false;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	create_task_ui.show();
	edit_task_ui.hide();
	all_tasks_list.hide();
	
	user_label.text = USER_LABEL_TEXT % User.USERNAME;


func _on_create_task_button_pressed() -> void:
	create_task_ui.show();
	edit_task_ui.hide();
	all_tasks_list.hide();

func _on_get_random_task_button_pressed() -> void:
	create_task_ui.hide();
	edit_task_ui.open_random();
	all_tasks_list.hide();

func _on_all_tasks_list_item_selected(index: int) -> void:
	create_task_ui.hide();
	var selected_task_data = all_tasks_list.get_item_metadata(index);
	edit_task_ui.open(selected_task_data.id);
	all_tasks_list.hide();

func _on_create_task_ui_task_created() -> void:
	all_tasks_list.show();
	_reload_tasks();

func _on_task_ui_task_completed() -> void:
	all_tasks_list.show();
	_reload_tasks();

func _on_task_ui_task_edited() -> void:
	all_tasks_list.show();
	_reload_tasks();

func _on_create_task_ui_create_task_ui_closed() -> void:
	if not task_list_has_been_loaded_first_time:
		_reload_tasks();
	all_tasks_list.show();

func _on_edit_task_ui_edit_task_ui_closed() -> void:
	if not task_list_has_been_loaded_first_time:
		_reload_tasks();
	all_tasks_list.show();

func _on_sign_out_button_pressed() -> void:
	User.sign_out();
	user_label.text = "";


func _reload_tasks() -> void:
	task_list_has_been_loaded_first_time = true;
	await get_tree().create_timer(0.5).timeout; # To give time for the submission to be processed
	all_tasks_list.clear();
	var all_tasks_response : Array = await backend_client.get_tasks();
	for task in all_tasks_response:
		all_tasks_list.add_item(task.label);
		all_tasks_list.set_item_metadata(all_tasks_list.item_count - 1, task);
