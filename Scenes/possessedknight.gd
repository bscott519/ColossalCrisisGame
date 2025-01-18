extends CharacterBody2D

@onready var animated_sprite_2d = $AnimatedSprite2D

var speed = 32
var gravity = 10

func _ready():
	animated_sprite_2d.play("walk")

func _process(delta):
	move()
	
	move_and_slide()

func move():
	velocity.x = -speed 
	velocity.y += gravity
