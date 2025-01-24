extends Area2D

var plyr_dmg: int = 0

func _on_body_entered(body):
	if body.is_in_group("enemies"):
		body.take_dmg(plyr_dmg)
