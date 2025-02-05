extends Area2D

func _on_body_entered(body):
	if body.is_in_group("player"):
		Scenemanager.set_last_scene(get_tree().current_scene.scene_file_path)
		body.queue_free()
		get_tree().change_scene_to_file("res://Scenes/game_over.tscn")
