extends Control

func resume():
	get_tree().paused = false
	$".".hide()

func pause():
	get_tree().paused = true
	$".".show()

func testPause():
	if Input.is_action_just_pressed("pause") and get_tree().paused == false:
		pause()
	elif Input.is_action_just_pressed("pause") and get_tree().paused == true:
		resume()

func _on_resume_pressed():
	resume()

func _on_controls_pressed():
	pass

func _on_quit_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

func _process(delta):
	testPause()
