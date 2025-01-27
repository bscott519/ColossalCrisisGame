extends CharacterBody2D

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var timer = $Timer
@export var patrol_points : Node
@export var speed : int = 3000
@export var wait_time : int = 1

const GRAVITY = 1000

enum State { Idle, Walk, Attack, Death}
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
var chase_speed: float = 150  # Movement speed while chasing
var is_chasing: bool = false  # Whether the enemy is chasing the player

# Called when the node enters the scene tree
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
	
	if not $Detection/CollisionShape2D.shape:
		$Detection/CollisionShape2D.shape = RectangleShape2D.new()
		print("Assigned a new RectangleShape2D for detection.")

	# Set initial detection size (example: Width = 300, Height = 200)
	var new_extents = Vector2(30, 30)  # Half of desired width and height
	set_detection_radius(new_extents)
	set_attack_radius(50)  # Set attack radius to 50

# Called every physics frame
func _physics_process(delta):
	enemy_gravity(delta)
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
		timer.start()
	
	animated_sprite_2d.flip_h = dir.x < 0

func enemy_animations():
	if current_state == State.Idle && !can_walk:
		animated_sprite_2d.play("idle")
	elif current_state == State.Walk && can_walk:
		animated_sprite_2d.play("walk")
	elif current_state == State.Attack && !can_walk:
		animated_sprite_2d.play("attack")

func set_detection_radius(new_extents: Vector2):
	var detection_shape = $Detection/CollisionShape2D.shape
	if detection_shape and detection_shape is RectangleShape2D:
		detection_shape.extents = new_extents
		print("Detection extents updated:", new_extents)
	else:
		print("Error: Detection shape is not a RectangleShape2D!")

func set_attack_radius(new_radius: float):
	var attack_shape = $AttackRadius/CollisionShape2D.shape
	if attack_shape is CircleShape2D:
		attack_shape.radius = new_radius
		attack_radius = new_radius
	else:
		print("Error: Attack shape is not a CircleShape2D!")

# Chase behavior
func chase_player(delta):
	if player:
		direction = sign(player.global_position.x - global_position.x)  # Determine direction
		velocity.x = chase_speed * direction  # Move toward the player
		animated_sprite_2d.flip_h = direction < 1

		# Attack if close enough
		if global_position.distance_to(player.global_position) <= attack_radius:
			velocity.x = 0  # Stop moving to attack
			attack_player()

# Attack behavior
func attack_player():
	print("Enemy is attacking!")  # Replace with attack logic
	animated_sprite_2d.play("attack")
	# You can implement animations, damage logic, etc., here

func _on_detection_body_entered(body):
	if body.is_in_group("player"):
		print("Player entered detection zone.")
		player = body  # Store the reference to the player
		is_chasing = true

func _on_detection_body_exited(body):
	if body == player:
		player = null  # Clear the player reference
		is_chasing = false

func _on_timer_timeout():
	can_walk = true
