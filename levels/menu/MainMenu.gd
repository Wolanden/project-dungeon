extends Control



func _on_start_pressed():
	get_tree().change_scene_to_file("res://levels/village/village.tscn")

func _on_quit_pressed():
	get_tree().quit()


func _on_ready():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
