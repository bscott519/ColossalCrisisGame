extends CharacterBody2D

enum State { IDLE, CHASE, STOMP, SLAM, SUMMON }

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var detection_area = $Detection
@onready var attack_cooldown = $AttackCooldown
@onready var attack_radius = $AttackRadius

var current_state = State.IDLE
var player = null
var speed = 70
var attack_range = 80

func _ready():
	detection_area.connect("body_entered", _on_body_entered)
	attack_radius.connect("body_entered", _on_attack_radius_body_entered)
	attack_cooldown.start()

func _physics_process(delta):
	match current_state:
		State.IDLE:
			# Do nothing until player is found
			pass

		State.CHASE:
			if player:
				animated_sprite_2d.play("walk")
				var direction = (player.global_position - global_position).normalized()
				velocity = direction * speed
				
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
		print("Player entered attack radius")
		choose_attack()

func change_state(new_state):
	current_state = new_state
	match new_state:
		State.STOMP:
			print("Entering STOMP")
			velocity = Vector2.ZERO
			animated_sprite_2d.play("stomp")
			attack_cooldown.start()
			
		State.SLAM:
			print("Entering SLAM")
			velocity = Vector2.ZERO
			animated_sprite_2d.play("slam")
			attack_cooldown.start()
			
		State.SUMMON:
			print("Entering SUMMON")
			velocity = Vector2.ZERO
			animated_sprite_2d.play("rock_summon")
			attack_cooldown.start()

#func spawn_spikes():
	#var spike_scene = preload("res://scenes/SpikedRock.tscn")
	#var spike = spike_scene.instantiate()
	#spike.global_position = global_position + Vector2(0, 100)
	#get_tree().current_scene.add_child(spike)

func _on_animated_sprite_2d_animation_finished():
	match current_state:
		State.STOMP, State.SLAM, State.SUMMON:
			print("Finished attack animation:", current_state)
			change_state(State.CHASE)
