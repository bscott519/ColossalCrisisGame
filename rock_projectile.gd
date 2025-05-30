extends Area2D

@export var speed = 200
@export var dir: Vector2 = Vector2.ZERO
@export var dmg: int = 2

func _physics_process(delta):
	position += dir.normalized() * speed * delta

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.plyr_take_dmg(dmg, dir)
		queue_free()

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	await get_tree().create_timer(1.0).timeout  # Auto-destroy after 2 sec
	queue_free()
