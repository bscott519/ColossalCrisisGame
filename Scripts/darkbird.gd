extends CharacterBody2D

const speed = 30
var dir: Vector2

var is_chasing: bool

func _ready():
	is_chasing = false

func _process(delta):
	move(delta)
	handle_anims()

func move(delta):
	if !is_chasing:
		velocity += dir * speed * delta
	move_and_slide()

func _on_timer_timeout():
	$Timer.wait_time = choose([1.0, 1.5, 2.0])
	if !is_chasing:
		dir = choose([Vector2.RIGHT, Vector2.UP, Vector2.LEFT, Vector2.DOWN])
		print(dir)

func handle_anims():
	var animated_sprite = $AnimatedSprite2D
	animated_sprite.play("flying")
	if dir.x == -1:
		animated_sprite.flip_h = true
	elif dir.x == 1:
		animated_sprite.flip_h = false

func choose(array):
	array.shuffle()
	return array.front()
