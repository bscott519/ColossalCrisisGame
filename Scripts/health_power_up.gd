extends Node

@export var pickupAmount: int = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_health_pickup_body_entered(body):
	if body.is_in_group("player"):
		$HealthPick.play()
		if body.health < body.max_health: 
			body.health = min(body.health + pickupAmount, body.max_health) 
			body.healthChanged.emit(body.health)  
			print("Player health increased to: ", body.health)
		queue_free()
