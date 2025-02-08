extends Control

func _on_back_pressed():
	print("Last played scene: ", Scenemanager.last_played_scene)
	get_tree().paused = false
	if Scenemanager.last_played_scene != "":
		get_tree().change_scene_to_file(Scenemanager.last_played_scene)
