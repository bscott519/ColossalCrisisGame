extends Control

@onready var lvl = $"../../"

func _on_resume_pressed():
	lvl.pauseToggle()

func _on_controls_pressed():
	pass # Replace with function body.

func _on_quit_pressed():
	get_tree().quit
