@tool

extends EditorScript

# Execute with Ctrl + Shift + X
# For manual testing purposes
# https://docs.godotengine.org/en/stable/tutorials/plugins/running_code_in_the_editor.html#running-one-off-scripts-using-editorscript 

# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var file_path = "user://example.txt"  # Path to the file you want to delete

	if FileAccess.file_exists(file_path):
		var dir = DirAccess.open("user://")  # Open the directory where the file is stored
		if dir:
			var result = dir.remove(file_path)  # Attempt to delete the file
			if result == OK:
				print("File deleted successfully!");
			else:
				print("Failed to delete file.")
	else:
		print("File does not exist.")
