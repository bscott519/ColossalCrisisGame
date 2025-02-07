extends CharacterBody2D

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var dk_deal_damage_area = $CBDealDamageArea
@onready var walk_timer = $Timer
@export var patrol_points : Node
@export var speed : int = 4000
@export var wait_time : int = 1

const GRAVITY = 1000
var knockback_strength : float = 500
var is_knocked_back: bool = false
var knockback_dur: float = 0.2

enum State { Idle, Walk, Death}
var current_state : State
var dir : Vector2 = Vector2.LEFT
var direction: int = 1
var number_of_points : int
var point_positions : Array[Vector2]
var current_point : Vector2
var current_point_position : int
var can_walk : bool

# Chase and attack variables
var player: Node = null  # Reference to the player node
var detection_radius: float = 200  # Radius to detect the player
var attack_radius: float = 40  # Radius to attack the player
var chase_speed: float = 120  # Movement speed while chasing
var is_chasing: bool = false  # Whether the enemy is chasing the player
var dead: bool = false
var took_dmg: bool = false
var health = 5
var max_health = 5
var min_health = 0
var dmg_to_deal = 1
var is_deal_dmg: bool = false

# Called when the node enters the scene tree
func _ready():
	dk_deal_damage_area.cB_dmg = 1
	
	if patrol_points != null:
		number_of_points = patrol_points.get_children().size()
		for point in patrol_points.get_children():
			point_positions.append(point.global_position)
		current_point = point_positions[current_point_position]
	else:
		print("No patrol points")
	
	walk_timer.wait_time = wait_time
	
	current_state = State.Idle
	
	if not $Detection/CollisionShape2D.shape:
		$Detection/CollisionShape2D.shape = RectangleShape2D.new()
		print("Assigned a new RectangleShape2D for detection.")

	# Set initial detection size (example: Width = 300, Height = 200)
	var new_extents = Vector2(20, 30)  # Half of desired width and height
	set_detection_radius(new_extents)
	#set_attack_radius(30)  # Set attack radius to 50

# Called every physics frame
func _physics_process(delta):
	if current_state == State.Death:
		velocity = Vector2.ZERO 
		return 
	
	enemy_gravity(delta)
	
	if is_knocked_back:
		move_and_slide()
		return
	
	enemy_idle(delta)
	enemy_walk(delta)
	
	if is_chasing:
		chase_player(delta)
		$AnimatedSprite2D.play("walk")
	elif abs(velocity.x) > 0:
		$AnimatedSprite2D.play("walk")
	move_and_slide()
	enemy_animations()

func enemy_gravity(delta):
	velocity.y += GRAVITY * delta

func enemy_idle(delta):
	if !can_walk:
		velocity.x = move_toward(velocity.x, 0, speed * delta)
		current_state = State.Idle

func enemy_walk(delta):
	if !can_walk:
		return
	
	if abs(position.x - current_point.x) > 0.5:
		velocity.x = dir.x * speed * delta
		current_state = State.Walk
	else:
		current_point_position += 1

		if current_point_position >= number_of_points:
			current_point_position = 0

		current_point = point_positions[current_point_position];

		if current_point.x > position.x:
			dir = Vector2.RIGHT
		else:
			dir = Vector2.LEFT
		
		can_walk = false
		walk_timer.start()
	
	animated_sprite_2d.flip_h = dir.x > 0

func enemy_animations():
	#if current_state == State.Attack:
		#if animated_sprite_2d.animation != "attack":  # Prevent re-triggering
			#print("Forcing attack animation")
			#animated_sprite_2d.play("attack")
			#return  # Do NOT allow any other animations to play during attack

	if current_state == State.Death:
		print("Playing death animation")
		animated_sprite_2d.play("death")
		self.queue_free()
		return

	elif current_state == State.Walk and can_walk:
		animated_sprite_2d.play("walk")
	else:
		animated_sprite_2d.play("idle")

func set_detection_radius(new_extents: Vector2):
	var detection_shape = $Detection/CollisionShape2D.shape
	if detection_shape and detection_shape is RectangleShape2D:
		detection_shape.extents = new_extents
		print("Detection extents updated:", new_extents)
	else:
		print("Error: Detection shape is not a RectangleShape2D!")

# Chase behavior
func chase_player(delta):
	if player:
		#if current_state == State.Attack:
			#velocity.x = 0
			#return
		
		direction = sign(player.global_position.x - global_position.x)  # Determine direction
		velocity.x = chase_speed * direction  # Move toward the player
		animated_sprite_2d.flip_h = direction < 1

		# Attack if close enough
		if global_position.distance_to(player.global_position) <= attack_radius:
			print("Enemy is close enough to attack!")
			velocity.x = 0  # Stop moving to attack
			attack_player()

# Attack behavior
func attack_player():
	if dead:
		return
	
	if not is_deal_dmg:  # Prevent re-triggering the attack while it's already happening
		#print("Enemy is attacking!")
		#current_state = State.Attack
		#velocity.x = 0
		#animated_sprite_2d.stop()
		#animated_sprite_2d.play("attack")
		#print("Playing attack animation: ", animated_sprite_2d.animation)
		
		# Enable the damage area
		$CBDealDamageArea/CollisionShape2D.disabled = false
		is_deal_dmg = true  # Mark the enemy as dealing damage
		
		# Wait for attack duration and disable the damage area
		#await get_tree().create_timer(0.9).timeout  # Replace 1.0 with the duration of the attack animation
		await animated_sprite_2d.animation_finished
		print("Attack animation finished.")
		
		current_state = State.Walk
		$CBDealDamageArea/CollisionShape2D.disabled = true
		is_deal_dmg = false 

func take_dmg(dmg, knockback_dir):
	health -= dmg
	apply_knockback(knockback_dir)
	took_dmg = true
	if health <= min_health:
		health = min_health
		current_state = State.Death
		dead = true
		is_chasing = false
		can_walk = false
		velocity = Vector2.ZERO
		
		$CBDealDamageArea/CollisionShape2D.set_deferred("disabled", true)
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

func _on_detection_body_entered(body):
	if body.is_in_group("player"):
		print("Player entered detection zone.")
		player = body
		is_chasing = true

func _on_detection_body_exited(body):
	if body == player:
		if not is_deal_dmg:
			player = null 
			is_chasing = false
		is_chasing = false

func _on_timer_timeout():
	can_walk = true
