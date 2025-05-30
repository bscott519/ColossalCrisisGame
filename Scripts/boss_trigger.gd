extends Area2D

signal playerEntered

@onready var boss_door = $"../BossDoor"
@onready var boss_door_2 = $"../BossDoor2"

func _physics_process(delta):
	var bodies = get_overlapping_bodies()
	for body in bodies:
		if body.name == "player":
			emit_signal("playerEntered")
			
			boss_door._on_boss_trigger_player_entered()
			boss_door_2._on_boss_trigger_player_entered()
			
			queue_free()
