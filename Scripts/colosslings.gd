extends CharacterBody2D

class_name Colossling

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var timer = $Timer
@onready var cl_deal_dmg_area = $CLDealDmgArea

@export var patrol_points : Node
@export var speed : int = 1500
@export var wait_time : int = 1

const gravity = 900

enum State { Idle, Walk, Death }
var current_state : State
var direction : Vector2 = Vector2.LEFT
var number_of_points : int
var point_positions : Array[Vector2]
var current_point : Vector2
var current_point_position : int

var knockback_strength : float = 100
var is_knocked_back: bool = false
var knockback_dur: float = 0.2

var is_chasing: bool
var dir: Vector2
var can_walk: bool
var took_dmg: bool = false
var dead: bool = false
var health = 1
var max_health = 1
var min_health = 0
var dmg_to_deal = 1
var is_deal_dmg: bool = false
var is_roaming: bool = true
var player: CharacterBody2D
var player_in_area = false

func _ready():
	if patrol_points != null:
		number_of_points = patrol_points.get_children().size()
		for point in patrol_points.get_children():
			point_positions.append(point.global_position)
		current_point = point_positions[current_point_position]
	else:
		print("No patrol points")
	
	timer.wait_time = wait_time
	
	current_state = State.Idle
	
	cl_deal_dmg_area.cL_dmg = 1

func _physics_process(delta):
	Global.cLDmgAmount = dmg_to_deal
	Global.cLDmgZone = $CLDealDmgArea
	player = Global.plyrbody

	if Global.plyrAlive:
		is_chasing = true
	elif !Global.plyrAlive:
		is_chasing = false
		
	if is_knocked_back:
		move_and_slide()
	else:
		pass

	enemy_gravity(delta)
	enemy_idle(delta)
	enemy_walk(delta)
	enemy_anims()
	move_and_slide()

func _on_timer_timeout():
	can_walk = true

func enemy_gravity(delta : float):
	velocity.y += gravity * delta

func enemy_idle(delta : float):
	if !can_walk:
		velocity.x = move_toward(velocity.x, 0, speed * delta)
		current_state = State.Idle

func enemy_walk(delta):
	if !dead:
		if abs(position.x - current_point.x) > 0.5:
			velocity.x = direction.x * speed * delta
			current_state = State.Walk
		else:
			current_point_position += 1

			if current_point_position >= number_of_points:
				current_point_position = 0

			current_point = point_positions[current_point_position];

			if current_point.x > position.x:
				direction = Vector2.RIGHT
			else:
				direction = Vector2.LEFT
			
			can_walk = false
			timer.start()
	
	animated_sprite_2d.flip_h = direction.x > 0

func enemy_death():
	self.queue_free()

func enemy_anims():
	if current_state == State.Death:
		animated_sprite_2d.play("death")
	elif current_state == State.Idle && !can_walk:
		animated_sprite_2d.play("idle")
	elif current_state == State.Walk && can_walk:
		animated_sprite_2d.play("walk")
	
	if !dead and !took_dmg and !is_deal_dmg:
		animated_sprite_2d.play("walk")
		if dir.x == -1:
			animated_sprite_2d.flip_h = true
		elif dir.x == 1:
			animated_sprite_2d.flip_h = false
	elif !dead and took_dmg and !is_deal_dmg:
		animated_sprite_2d.play("hurt")
		await get_tree().create_timer(0.6).timeout
		took_dmg = false
	elif dead and is_roaming:
		is_roaming = false
		current_state = State.Death
		velocity.x = 0
		animated_sprite_2d.play("death")
		await get_tree().create_timer(0.4).timeout
		enemy_death()
	
func take_dmg(dmg, knockback_dir):
	health -= dmg
	apply_knockback(knockback_dir)
	took_dmg = true
	if health <= min_health:
		health = min_health
		dead = true
		
		$CLDealDmgArea/CollisionShape2D.set_deferred("disabled", true)
		
	print(str(self), "current health is ", health)

func apply_knockback(knockback_dir: Vector2):
	is_knocked_back = true
	velocity = knockback_dir * knockback_strength  
	await get_tree().create_timer(knockback_dur).timeout 
	is_knocked_back = false 
	velocity = Vector2.ZERO

func attack():
	$CLDealDmgArea/CollisionShape2D.disabled = false
	await await get_tree().create_timer(1.0).timeout
	$CLDealDmgArea/CollisionShape2D.disabled = true
