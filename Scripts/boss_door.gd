extends StaticBody2D

signal isClosed

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_boss_trigger_player_entered():
	$AnimationPlayer.play("Active")
	await get_tree().create_timer(1.3).timeout
	$AnimationPlayer.play("Closed")
	emit_signal('isClosed')

func open_doors():
	$AnimationPlayer.play("Opening")
