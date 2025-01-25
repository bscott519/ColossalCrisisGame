extends CharacterBody2D

@onready var animated_sprite_2d = $AnimatedSprite2D

var patrol_points: Array = []  # Array of Vector2 patrol points
var patrol_index: int = 0  # Current target patrol point
var patrol_speed: float = 100  # Movement speed while patrolling

# Chase and attack variables
var player: Node = null  # Reference to the player node
var detection_radius: float = 200  # Radius to detect the player
var attack_radius: float = 40  # Radius to attack the player
var chase_speed: float = 150  # Movement speed while chasing
var is_chasing: bool = false  # Whether the enemy is chasing the player

# Other variables
var direction: int = 1  # Current movement direction (1 for right, -1 for left)

# Called when the node enters the scene tree
func _ready():
	patrol_points = [Vector2(100, position.y), Vector2(300, position.y)]  # Example patrol points
	
	if not $Detection/CollisionShape2D.shape:
		$Detection/CollisionShape2D.shape = RectangleShape2D.new()
		print("Assigned a new RectangleShape2D for detection.")

	# Set initial detection size (example: Width = 300, Height = 200)
	var new_extents = Vector2(30, 50)  # Half of desired width and height
	set_detection_radius(new_extents)
	set_attack_radius(50)  # Set attack radius to 50

# Called every physics frame
func _physics_process(delta):
	if is_chasing:
		chase_player(delta)
		$AnimatedSprite2D.play("walk")
	elif abs(velocity.x) > 0:
		$AnimatedSprite2D.play("walk")
	else:
		patrol(delta)
		$AnimatedSprite2D.play("walk")
	move_and_slide()

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

# Patrol behavior
func patrol(delta):
	var target = patrol_points[patrol_index]  # Current patrol point
	direction = sign(target.x - position.x)  # Determine direction (-1 or 1)
	velocity.x = patrol_speed * direction  # Move toward the target

	# Flip direction if near the patrol point
	if abs(target.x - position.x) < 5:
		patrol_index = (patrol_index + 1) % patrol_points.size()  # Cycle to the next patrol point

# Chase behavior
func chase_player(delta):
	if player:
		direction = sign(player.global_position.x - global_position.x)  # Determine direction
		velocity.x = chase_speed * direction  # Move toward the player

		# Attack if close enough
		if global_position.distance_to(player.global_position) <= attack_radius:
			velocity.x = 0  # Stop moving to attack
			attack_player()

# Attack behavior
func attack_player():
	print("Enemy is attacking!")  # Replace with attack logic
	$AnimatedSprite2D.play("attack")
	# You can implement animations, damage logic, etc., here

func _on_detection_body_entered(body):
	if body.is_in_group("player"):
		player = body  # Store the reference to the player
		is_chasing = true

func _on_detection_body_exited(body):
	if body == player:
		player = null  # Clear the player reference
		is_chasing = false
