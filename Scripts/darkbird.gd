extends CharacterBody2D

const speed = 30
var dir: Vector2

var is_chasing: bool

var player: CharacterBody2D

var health = 15
var max_health = 15
var min_health = 0
var dead = false
var took_dmg = false
var is_roaming: bool

func _ready():
	is_chasing = true

func _process(delta):
	if is_on_floor() and dead:
		await get_tree().create_timer(2.0).timeout
		self.queue_free()
	
	move(delta)
	handle_anims()

func move(delta):
	player = Global.plyrbody
	if !dead:
		is_roaming = true
		if !took_dmg and is_chasing:
			velocity = position.direction_to(player.position) * speed
			dir.x = abs(velocity.x) / velocity.x
		elif took_dmg: 
			var knockback_dir = position.direction_to(player.position) * -50
			velocity = knockback_dir
		else:
			velocity += dir * speed * delta
	elif dead:
		velocity.y += 10 * delta
		velocity.x = 0
		is_roaming = false
	move_and_slide()

func _on_timer_timeout():
	$Timer.wait_time = choose([0.5, 0.8])
	if !is_chasing:
		dir = choose([Vector2.RIGHT, Vector2.UP, Vector2.LEFT, Vector2.DOWN])

func handle_anims():
	var animated_sprite = $AnimatedSprite2D
	if !dead and !took_dmg:
		animated_sprite.play("flying")
		if dir.x == -1:
			animated_sprite.flip_h = true
		elif dir.x == 1:
			animated_sprite.flip_h = false
	elif !dead and took_dmg:
		animated_sprite.play("hurt")
		await get_tree().create_timer(0.6).timeout
		took_dmg = false
	elif dead and is_roaming:
		is_roaming = false
		animated_sprite.play("death")
		set_collision_layer_value(1, true)
		set_collision_layer_value(2, false)
		set_collision_mask_value(1, true)
		set_collision_mask_value(2, false)

func choose(array):
	array.shuffle()
	return array.front()

func take_dmg(dmg):
	health -= dmg
	took_dmg = true
	if health <= 0:
		health = 0
		dead = true
	print(str(self), "current health is ", health)

func _on_hitbox_area_entered(area):
	if area == Global.plyrDmgZone:
		var dmg = Global.plyrDmgAmount
		take_dmg(dmg)
