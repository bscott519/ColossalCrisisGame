extends CharacterBody2D

const speed = 30
var dir: Vector2

var is_chasing: bool

var player: CharacterBody2D

func _ready():
	is_chasing = true

func _process(delta):
	move(delta)
	handle_anims()

func move(delta):
	if is_chasing:
		player = Global.plyrbody
		velocity = position.direction_to(player.position) * speed
		dir.x = abs(velocity.x) / velocity.x
	elif !is_chasing:
		velocity += dir * speed * delta
	move_and_slide()

func _on_timer_timeout():
	$Timer.wait_time = choose([0.5, 0.8])
	if !is_chasing:
		dir = choose([Vector2.RIGHT, Vector2.UP, Vector2.LEFT, Vector2.DOWN])
		

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
