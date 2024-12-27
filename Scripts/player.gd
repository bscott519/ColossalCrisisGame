extends CharacterBody2D

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var dmg_zone = $DamageZone

const SPEED = 200
const JUMP_VELOCITY = -380.0

var gravity = 900

var attack_type: String
var cur_attack: bool


func _ready():
	Global.plyrbody = self
	cur_attack = false

func _physics_process(delta):
	Global.plyrDmgZone = dmg_zone
	
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
		if Input.is_action_just_pressed("attack") or Input.is_action_just_pressed("double_attack"):
			cur_attack = true
			if Input.is_action_just_pressed("attack") and is_on_floor():
				attack_type = "single"
			elif Input.is_action_just_pressed("double_attack") and is_on_floor():
				attack_type = "double"
			else:
				attack_type = "air"
			set_dmg(attack_type)
			handle_attack_anims(attack_type)

	move_and_slide()
	player_anims(direction)

func player_anims(dir):
	if is_on_floor() and !cur_attack:
		if !velocity:
			animated_sprite_2d.play("idle")
		if velocity:
			animated_sprite_2d.play("run")
			toggle_flip(dir)
	elif !is_on_floor() and !cur_attack:
		animated_sprite_2d.play("jump")

func handle_attack_anims(attack_type):
	if cur_attack:
		var anim = str(attack_type, "_attack")
		animated_sprite_2d.play(anim)
		toggle_dmg_collisions(attack_type)

func toggle_dmg_collisions(attack_type):
	var dmg_zone_col = dmg_zone.get_node("CollisionShape2D")
	var wait_time: float
	if attack_type == "air":
		wait_time = 0.3
	elif attack_type == "single":
		wait_time = 0.3
	elif attack_type == "double":
		wait_time = 1.2
	dmg_zone_col.disabled = false
	await get_tree().create_timer(wait_time).timeout
	dmg_zone_col.disabled = true

func toggle_flip(dir):
	if dir == 1:
		animated_sprite_2d.flip_h = false
		dmg_zone.scale.x = 1
	if dir == -1:
		animated_sprite_2d.flip_h = true
		dmg_zone.scale.x = -1

func set_dmg(attack_type):
	var cur_dmg_to_deal: int

func _on_animated_sprite_2d_animation_finished():
	cur_attack = false
