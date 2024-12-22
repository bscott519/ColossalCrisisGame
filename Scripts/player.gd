extends CharacterBody2D

@onready var animated_sprite_2d = $AnimatedSprite2D

const SPEED = 200
const JUMP_VELOCITY = -380.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 900


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

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

func toggle_flip(dir):
	if dir == 1:
		animated_sprite_2d.flip_h = false
	if dir == -1:
		animated_sprite_2d.flip_h = true
