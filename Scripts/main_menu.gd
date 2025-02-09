extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	$TitleTheme.play()
	$TitleTheme.finished.connect(_on_title_theme_finished)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_start_pressed():
	get_tree().change_scene_to_file("res://Scenes/level_select.tscn")

func _on_controls_pressed():
	Scenemanager.set_last_scene(get_tree().current_scene.scene_file_path)
	get_tree().change_scene_to_file("res://Scenes/controlsscreen.tscn")

func _on_quit_pressed():
	get_tree().quit()

func _on_title_theme_finished():
	$TitleTheme.play()
