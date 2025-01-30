extends CanvasLayer

func _on_try_again_pressed():
	get_tree().change_scene_to_file("res://Scenes/level_1.tscn")

func _on_quit_pressed():
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
