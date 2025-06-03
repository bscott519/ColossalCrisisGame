extends CharacterBody2D

enum State { IDLE, CHASE, STOMP, SLAM, SUMMON, DEATH }

signal boss_died

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var detection_area = $Detection
@onready var attack_cooldown = $AttackCooldown
@onready var attack_radius = $AttackRadius
@onready var eg_deal_damage_area = $EGDealDamageArea
@onready var enable_eg_damage_area: Timer = $EnableEGDamageArea
@onready var disable_eg_damage_area: Timer = $DisableEGDamageArea
@onready var rock_projectile_scene = preload("res://Scenes/rock_projectile.tscn")

var player_in_attack_radius = false
var knockback_strength : float = 500
var is_knocked_back: bool = false
var knockback_dur: float = 0.2
var is_chasing: bool = false
var can_walk: bool

var eG_dmg: int = 0
var can_dmg: bool = true
var dmg_cooldown: float = 1.0

var current_state = State.IDLE
var player = null
var speed = 70
var attack_range = 80
var dead: bool = false
var took_dmg: bool = false
var health = 10
var max_health = 10
var min_health = 0
var dmg_to_deal = 2
var is_deal_dmg: bool = false

func _ready():
	detection_area.connect("body_entered", _on_body_entered)
	attack_radius.connect("body_entered", _on_attack_radius_body_entered)
	
	$EGDealDamageArea/CollisionShape2D.set_deferred("disabled", true)
	
	enable_eg_damage_area.timeout.connect(self._on_enable_eg_damage_area_timeout)
	disable_eg_damage_area.timeout.connect(self._on_disable_eg_damage_area_timeout)
	
	attack_cooldown.start()

func _physics_process(delta):
	$EGHealthBar.value = health
	
	match current_state:
		State.IDLE:
			# Do nothing until player is found
			pass

		State.CHASE:
			if player:
				animated_sprite_2d.play("walk")
				var direction = (player.global_position - global_position).normalized()
				velocity = direction * speed
				velocity.y = 0
				
				move_and_slide()
				
				var dist = global_position.distance_to(player.global_position)
				if dist < attack_range and !attack_cooldown.time_left > 0:
					choose_attack()
					print("Distance to player:", dist)
					
				animated_sprite_2d.flip_h = direction.x < 0
				
		State.STOMP, State.SLAM, State.SUMMON:
			velocity = Vector2.ZERO
	if current_state in [State.STOMP, State.SLAM, State.SUMMON]:
		return

func choose_attack():
	var rand = randi() % 3
	match rand:
		0: change_state(State.STOMP)
		1: change_state(State.SLAM)
		2: change_state(State.SUMMON)

func _on_body_entered(body):
	if body.name == "player":
		player = body
		change_state(State.CHASE)

func _on_attack_radius_body_entered(body):
	if body.name == "player":
		player = body
		player_in_attack_radius = true
		print("Player entered attack radius")
		choose_attack()

func _on_attack_radius_body_exited(body):
	if body.name == "player":
		player_in_attack_radius = false

func change_state(new_state):
	current_state = new_state
	match new_state:
		State.STOMP:
			print("Entering STOMP")
			velocity = Vector2.ZERO
			animated_sprite_2d.play("stomp")
			enable_eg_damage_area.start(0.5)
			disable_eg_damage_area.start(0.8)
			attack_cooldown.start()
			
		State.SLAM:
			print("Entering SLAM")
			velocity = Vector2.ZERO
			animated_sprite_2d.play("slam")
			enable_eg_damage_area.start(0.3)
			disable_eg_damage_area.start(0.6)
			attack_cooldown.start()
			
		State.SUMMON:
			print("Entering SUMMON")
			velocity = Vector2.ZERO
			animated_sprite_2d.play("rock_summon")
			spawn_rock()
			attack_cooldown.start()

func spawn_rock():
	var projectile = rock_projectile_scene.instantiate()
	projectile.global_position = global_position + Vector2(0, -20)
	projectile.dir = (player.global_position - global_position).normalized()
	get_tree().current_scene.add_child(projectile)

func _on_animated_sprite_2d_animation_finished():
	match current_state:
		State.STOMP, State.SLAM, State.SUMMON:
			print("Finished attack animation:", current_state)
			change_state(State.CHASE)
			attack_cooldown.start()

func _on_attack_cooldown_timeout():
	if player_in_attack_radius:
		choose_attack()

func take_dmg(dmg, knockback_dir):
	health -= dmg
	apply_knockback(knockback_dir)
	took_dmg = true
	if health <= min_health:
		health = min_health
		current_state = State.DEATH
		dead = true
		animated_sprite_2d.play("death")
		is_chasing = false
		can_walk = false
		velocity = Vector2.ZERO
		emit_signal("boss_died")
		
		$EGDealDamageArea/CollisionShape2D.set_deferred("disabled", true)
		print("Enemy is dead. Disabling damage collision shape.")
		
		animated_sprite_2d.stop()
		animated_sprite_2d.play("death")
		print("Enemy is dying, playing death animation.")
		
		await get_tree().create_timer(1.0).timeout
		self.queue_free()
	print(str(self), "current health is ", health)

func apply_knockback(knockback_dir: Vector2):
	if is_knocked_back:
		return
	is_knocked_back = true
	velocity.x = knockback_dir.x * knockback_strength  
	velocity.y = 0
	
	move_and_slide()
	
	await get_tree().create_timer(knockback_dur).timeout 
	is_knocked_back = false 
	velocity.x = 0
	
	move_and_slide()
	
func _on_eg_deal_damage_area_body_entered(body):
	if can_dmg and body.is_in_group("player"):
		print("Player entered EGDealDamageArea.")
		var knockback_dir = (body.global_position - global_position).normalized()
		body.plyr_take_dmg(dmg_to_deal, knockback_dir)
		can_dmg = false
		start_dmg_cooldown()

func start_dmg_cooldown():
	await get_tree().create_timer(dmg_cooldown).timeout
	can_dmg = true

func _on_enable_eg_damage_area_timeout():
	enable_eg_timer()

func _on_disable_eg_damage_area_timeout():
	disable_eg_timer()
	
func enable_eg_timer():
	$EGDealDamageArea/CollisionShape2D.disabled = false
	is_deal_dmg = true

func disable_eg_timer():
	$EGDealDamageArea/CollisionShape2D.disabled = true
	is_deal_dmg = false
