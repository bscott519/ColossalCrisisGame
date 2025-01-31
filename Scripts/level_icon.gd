@tool
extends Control
class_name LevelIcon

@export var lvl_name := "1"
@export_file("*.tscn") var next_scene_path: String
@export var next_level_left: LevelIcon
@export var next_level_right: LevelIcon

# Called when the node enters the scene tree for the first time.
func _ready():
	$Label.text = "Level " + str(lvl_name)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Engine.is_editor_hint():
		$Label.text = "Level " + str(lvl_name)
