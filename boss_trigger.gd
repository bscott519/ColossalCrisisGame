extends Area2D

signal playerEntered

func _physics_process(delta):
	var bodies = get_overlapping_bodies()
	for body in bodies:
		if body.name == "player":
			emit_signal("playerEntered")
			queue_free()
