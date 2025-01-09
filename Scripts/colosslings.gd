extends CharacterBody2D

class_name Colossling

@export var patrol_points: Node
@export var speed: int = 1500
@export var wait_time: int = 2

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var timer = $Timer

const gravity = 1000

enum State { Idle, Walk, Hurt, Death }
var cur_state: State
var dir: Vector2 = Vector2.LEFT
var num_of_points: int
var point_positions: Array[Vector2]
var cur_point: Vector2
var cur_point_pos: int
var can_walk: bool
var took_dmg: bool = false
var dead: bool = false
var health = 10
var max_health = 10
var min_health = 0
var dmg_to_deal = 10
var is_deal_dmg: bool = false
var knockback_force = 200

func _ready():
	if patrol_points != null:
		num_of_points = patrol_points.get_children().size()
		for point in patrol_points.get_children():
			point_positions.append(point.global_position)
		cur_point = point_positions[cur_point_pos]
	else:
		print("No patrol points")
		
	timer.wait_time = wait_time

	cur_state = State.Idle

func _physics_process(delta: float):
	enemy_gravity(delta)
	enemy_idle(delta)
	enemy_walk(delta)
	
	move_and_slide()
	
	enemy_anims()

func enemy_gravity(delta: float):
	velocity.y += gravity * delta

func enemy_idle(delta: float):
	if !can_walk:
		velocity.x = move_toward(velocity.x, 0, speed * delta)
		cur_state = State.Idle

func enemy_walk(delta: float):
	if !can_walk:
		return
	if abs(position.x -cur_point.x) > 0.5:
		velocity.x = dir.x * speed * delta
		cur_state = State.Walk
	else:
		cur_point_pos += 1
	
		if cur_point_pos >= num_of_points:
			cur_point_pos = 0
		
		cur_point = point_positions[cur_point_pos]
		
		if cur_point.x > position.x:
			dir = Vector2.RIGHT
		else:
			dir = Vector2.LEFT
		
		can_walk = false
		timer.start()

	animated_sprite_2d.flip_h = dir.x > 0

func _on_timer_timeout():
	can_walk = true

func enemy_anims():
	if cur_state == State.Idle && !can_walk:
		animated_sprite_2d.play("idle")
	elif cur_state == State.Walk && can_walk:
		animated_sprite_2d.play("walk")
	elif cur_state == State.Death && health == min_health:
		animated_sprite_2d.play("death")

func _on_cl_hitbox_area_entered(area):
	var dmg = Global.plyrDmgAmount
	if area == Global.plyrDmgZone:
		take_dmg(dmg)
	
func take_dmg(dmg):
	health -= dmg
	took_dmg = true
	if health <= min_health:
		health = min_health
		dead = true
		cur_state = State.Death
		await get_tree().create_timer(0.5).timeout
		self.queue_free()
	print(str(self), "current health is ", health)
