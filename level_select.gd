extends Control
class_name LevelSelect

@onready var cur_lvl: LevelIcon = $LevelIcon

# Called when the node enters the scene tree for the first time.
func _ready():
	$PlayerIcon.global_position = cur_lvl.global_position

func _input(event):
	if event.is_action_pressed("left") and cur_lvl.next_level_left:
		cur_lvl = cur_lvl.next_level_left
		$PlayerIcon.global_position = cur_lvl.global_position
	if event.is_action_pressed("right") and cur_lvl.next_level_right:
		cur_lvl = cur_lvl.next_level_right
		$PlayerIcon.global_position = cur_lvl.global_position
	
	if event.is_action_pressed("enter"):
		if cur_lvl.next_scene_path:
			get_tree().change_scene_to_file(cur_lvl.next_scene_path)

func _on_back_pressed():
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

