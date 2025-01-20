extends CharacterBody2D

@onready var animated_sprite_2d = $AnimatedSprite2D

var speed = 32
var gravity = 10
var is_moving_left = true

func _ready():
	animated_sprite_2d.play("walk")

func _process(delta):
	move()
	turn_around()
	
	move_and_slide()

func move():
	if is_moving_left:
		velocity.x = -speed
	else:
		velocity.x = speed
	
	velocity.y += gravity

func turn_around():
	if not $RayCast2D.is_colliding() and is_on_floor():
		is_moving_left = !is_moving_left
		scale.x = -scale.x
