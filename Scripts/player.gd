extends CharacterBody2D

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var dmg_zone = $DamageZone

const SPEED = 200
const JUMP_VELOCITY = -380.0

var gravity = 900

var health = 40
var max_health = 40
var min_health = 0
var can_take_dmg: bool
var dead: bool

var attack_type: String
var cur_attack: bool

func _ready():
	Global.plyrbody = self
	cur_attack = false
	dead = false
	can_take_dmg = true
	Global.plyrAlive = true

func _physics_process(delta):
	Global.plyrDmgZone = dmg_zone

	if not is_on_floor():
		velocity.y += gravity * delta

	if !dead:
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
		player_anims(direction)
		check_hitbox()
	move_and_slide()

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
	$Camera2D.zoom.x = 4
	$Camera2D.zoom.y = 4
	await get_tree().create_timer(3.5).timeout
	self.queue_free()

func take_dmg_cooldown(wait_time): 
	can_take_dmg = false
	await get_tree().create_timer(wait_time).timeout
	can_take_dmg = true

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
	if attack_type == "single":
		cur_dmg_to_deal = 5
	elif attack_type == "double":
		cur_dmg_to_deal = 5
	elif attack_type == "air":
		cur_dmg_to_deal = 5
	Global.plyrDmgAmount = cur_dmg_to_deal

func _on_animated_sprite_2d_animation_finished():
	cur_attack = false
