extends CharacterBody2D

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var dag_zone = $DamageZone

const SPEED = 200
const JUMP_VELOCITY = -380.0

var gravity = 900

var attack_type: String
var cur_attack: bool


func _ready():
	Global.plyrbody = self
	cur_attack = false

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var direction = Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	if !cur_attack:
		if Input.is_action_just_pressed("left_mouse") or Input.is_action_just_pressed("right_mouse"):
			cur_attack = true
			if Input.is_action_just_pressed("left_mouse") and is_on_floor():
				attack_type = "single"
			elif Input.is_action_just_pressed("right_mouse") and is_on_floor():
				attack_type = "double"
			else:
				attack_type = "air"
			handle_attack_anims(attack_type)

	move_and_slide()
	player_anims(direction)

func player_anims(dir):
	if is_on_floor():
		if !velocity:
			animated_sprite_2d.play("idle")
		if velocity:
			animated_sprite_2d.play("run")
			toggle_flip(dir)
	elif !is_on_floor():
		animated_sprite_2d.play("jump")

func handle_attack_anims(attack_type):
	pass

func toggle_flip(dir):
	if dir == 1:
		animated_sprite_2d.flip_h = false
	if dir == -1:
		animated_sprite_2d.flip_h = true
