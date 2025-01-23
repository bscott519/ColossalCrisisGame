class_name Player
extends CharacterBody2D

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var combo_reset = $ComboReset
@onready var dmg_zone = $DamageZone

const SPEED = 200
const JUMP_VELOCITY = -380.0
var gravity = 900

enum attack_states { Reset, Attack1, Attack2, Attack3 }
enum air_attack_states { Reset, AirAttack1, AirAttack2 }
var last_attack = attack_states.Reset
var last_air_attack = air_attack_states.Reset
var doAttack = false

var health = 40
var max_health = 40
var min_health = 0
var can_take_dmg: bool
var dead: bool

func _ready():
	Global.plyrbody = self

func _physics_process(delta):
	Global.plyrDmgZone = dmg_zone
	Global.plyrHitbox = $PlayerHitbox
	
	velocity.y += gravity * delta
	
	if not doAttack:
		handle_hor_movement()
		
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY
			animated_sprite_2d.play("jump")
		elif not is_on_floor():
			animated_sprite_2d.play("jump")
		elif velocity.x == 0 and is_on_floor():
			animated_sprite_2d.play('idle')

	attack_anims()
	check_hitbox()
	move_and_slide()
	
func handle_hor_movement():
	if Input.is_action_pressed("left"):
		print("Left input detected")
		velocity.x = -SPEED
		animated_sprite_2d.play("run")
		animated_sprite_2d.flip_h = true
		dmg_zone.scale.x = -1
	elif Input.is_action_pressed("right"):
		print("Right input detected")
		velocity.x = SPEED
		animated_sprite_2d.play("run")
		animated_sprite_2d.flip_h = false
		dmg_zone.scale.x = 1
	else:
		velocity.x = 0

func attack_anims():
	if doAttack:
		velocity.x = 0
		return
	
	var dmg_zone_col = dmg_zone.get_node("CollisionShape2D")
	var wait_time: float
	var cur_dmg_to_deal: int
	
	if Input.is_action_just_pressed("attack") and !is_on_floor():
		doAttack = true

		if last_air_attack == air_attack_states.AirAttack1:
			last_air_attack = air_attack_states.AirAttack2
			animated_sprite_2d.play("airattack2")
			wait_time = 0.2
			cur_dmg_to_deal = 5
		else:
			last_air_attack = air_attack_states.AirAttack1
			animated_sprite_2d.play("airattack1")
			wait_time = 0.2
			cur_dmg_to_deal = 5
			
		dmg_zone_col.disabled = false
		await get_tree().create_timer(wait_time).timeout
		dmg_zone_col.disabled = true
		doAttack = false
		return
	
	if Input.is_action_just_pressed("attack"):
		doAttack = true
	
		if last_attack == attack_states.Attack2:
			last_attack = attack_states.Attack3
			animated_sprite_2d.play("attack3")
			wait_time = 0.3
			cur_dmg_to_deal = 5
		elif last_attack == attack_states.Attack1:
			last_attack = attack_states.Attack2
			animated_sprite_2d.play("attack2")
			wait_time = 0.2
			cur_dmg_to_deal = 5
		else:
			last_attack = attack_states.Attack1
			animated_sprite_2d.play("attack1")
			wait_time = 0.2
			cur_dmg_to_deal = 5
			
		dmg_zone_col.disabled = false
		await get_tree().create_timer(wait_time).timeout
		dmg_zone_col.disabled = true
		doAttack = false
	
	Global.plyrDmgAmount = cur_dmg_to_deal

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
	last_air_attack = air_attack_states.Reset
