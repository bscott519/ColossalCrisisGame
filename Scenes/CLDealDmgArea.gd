extends Area2D

var cL_dmg: int = 0
var can_dmg: bool = true
var dmg_cooldown: float = 1.0

func _on_body_entered(body):
	if can_dmg and body.is_in_group("player"):
		body.plyr_take_dmg(cL_dmg)
		can_dmg = false
		start_dmg_cooldown()

func start_dmg_cooldown():
	await get_tree().create_timer(dmg_cooldown).timeout
	can_dmg = true
