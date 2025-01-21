class_name Player
extends CharacterBody2D

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var combo_reset = $ComboReset
@onready var dmg_zone = $DamageZone

const SPEED = 200
const JUMP_VELOCITY = -380.0
var gravity = 900

enum attack_states { Reset, Attack1, Attack2, Attack3, AirAttack1, AirAttack2}
var last_attack = attack_states.Reset
var doAttack = false

var health = 40
var max_health = 40
var min_health = 0
var can_take_dmg: bool
var dead: bool

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var direction = Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	player_anims(direction)
	attack_anims()
	move_and_slide()
	
func player_anims(direction):
	if direction > 0:
		animated_sprite_2d.flip_h = false
	elif direction < 0:
		animated_sprite_2d.flip_h = true
		
	if !is_on_floor():
		animated_sprite_2d.play("jump")
	elif direction != 0:
		animated_sprite_2d.play("run")
	else:
		animated_sprite_2d.play("idle")

func attack_anims():
	if doAttack:
		return
	doAttack = true
	
	if Input.is_action_just_pressed("attack") && last_attack == attack_states.Attack2:
		last_attack = attack_states.Attack3
		animated_sprite_2d.play("attack3")
	elif Input.is_action_just_pressed("attack") && last_attack == attack_states.Attack1:
		last_attack = attack_states.Attack2
		animated_sprite_2d.play("attack2")
	elif Input.is_action_just_pressed("attack"):
		last_attack = attack_states.Attack1
		animated_sprite_2d.play("attack1")
	
	elif velocity.x > 0:
		animated_sprite_2d.play("run")
	elif velocity.x < 0:
		animated_sprite_2d.play("run")
	else:
		doAttack = false
		animated_sprite_2d.play("idle")

func check_hitbox():
	var hitbox_areas = $PlayerHitbox.get_overlapping_areas()
	var dmg: int
	if hitbox_areas:
		var hitbox = hitbox_areas.front()
		if hitbox.get_parent() is DarkBird:
			dmg = Global.birdDmgAmount
		elif hitbox.get_parent() is Colossling:
			dmg = Global.cLDmgAmount

	if can_take_dmg:
		take_dmg(dmg)

func take_dmg(dmg):
	if dmg != 0:
		if health > 0:
			health -= dmg
			print("plyer health: ", health)
			if health <= 0:
				health = 0
				dead = true
				Global.plyrAlive = false
				handle_death_anims()
			take_dmg_cooldown(1.0)

func handle_death_anims():
	$PlayerHitbox/CollisionShape2D.position.y = 5
	animated_sprite_2d.play("death")
	await get_tree().create_timer(0.5).timeout
	self.queue_free()

func take_dmg_cooldown(wait_time): 
	can_take_dmg = false
	await get_tree().create_timer(wait_time).timeout
	can_take_dmg = true

func toggle_dmg_collisions():
	var dmg_zone_col = dmg_zone.get_node("CollisionShape2D")
	var wait_time: float
	if animated_sprite_2d.animation == "single_attack":
		wait_time = 0.3
	dmg_zone_col.disabled = false
	await get_tree().create_timer(wait_time).timeout
	dmg_zone_col.disabled = true

func set_dmg(attack_type):
	var cur_dmg_to_deal: int
	if attack_type == "single":
		cur_dmg_to_deal = 5
	elif attack_type == "double":
		cur_dmg_to_deal = 5
	elif attack_type == "air":
		cur_dmg_to_deal = 5
	Global.plyrDmgAmount = cur_dmg_to_deal

func _on_animated_sprite_2d_animation_finished():
	doAttack = false
	combo_reset.start()

func _on_combo_reset_timeout():
	last_attack = attack_states.Reset
