extends CharacterBody2D

class_name Colossling

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var timer = $Timer
@onready var cl_deal_dmg_area = $CLDealDmgArea

const speed = 30
const gravity = 900

var is_chasing: bool
var dir: Vector2
var can_walk: bool
var took_dmg: bool = false
var dead: bool = false
var health = 10
var max_health = 10
var min_health = 0
var dmg_to_deal = 10
var is_deal_dmg: bool = false
var knockback_force = -50
var is_roaming: bool = true
var player: CharacterBody2D
var player_in_area = false

func _ready():
	is_chasing = true
	cl_deal_dmg_area.cL_dmg = 10

func _process(delta):
	if !is_on_floor():
		velocity.y += gravity * delta
		velocity.x = 0
	
	Global.cLDmgAmount = dmg_to_deal
	Global.cLDmgZone = $CLDealDmgArea
	player = Global.plyrbody

	if Global.plyrAlive:
		is_chasing = true
	elif !Global.plyrAlive:
		is_chasing = false

	enemy_walk(delta)
	enemy_anims()
	move_and_slide()

func _on_timer_timeout():
	$Timer.wait_time = choose([1.5, 2.0, 2.5])
	if !is_chasing:
		dir = choose([Vector2.RIGHT, Vector2.LEFT])
		velocity.x = 0

func choose(array):
	array.shuffle()
	return array.front()

func enemy_walk(delta):
	if !dead:
		if !is_chasing:
			velocity += dir * speed * delta
		elif is_chasing and !took_dmg:
			var dir_to_plyr = position.direction_to(player.position) * speed
			velocity.x = dir_to_plyr.x
			dir.x = abs(velocity.x) / velocity.x
		elif took_dmg:
			var knockback_dir = position.direction_to(player.position) * knockback_force
			velocity.x = knockback_dir.x
		is_roaming = true
	elif dead:
		velocity.x = 0

func enemy_death():
	self.queue_free()

func enemy_anims():
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
		animated_sprite_2d.play("death")
		await get_tree().create_timer(0.4).timeout
		enemy_death()
	
func take_dmg(dmg):
	health -= dmg
	took_dmg = true
	if health <= min_health:
		health = min_health
		dead = true
	print(str(self), "current health is ", health)

func attack():
	$CLDealDmgArea/CollisionShape2D.disabled = false
	await await get_tree().create_timer(1.0).timeout
	$CLDealDmgArea/CollisionShape2D.disabled = true
