extends CharacterBody2D

const gravity = 1000

enum State { Idle, Walk, Hurt, Death }
var cur_state: State

func _ready():
	cur_state = State.Idle

func _physics_process(delta: float):
	enemy_gravity(delta)
	
	move_and_slide()

func enemy_gravity(delta: float):
	velocity.y += gravity * delta
	
func enemy_idle(delta: float):
	pass
