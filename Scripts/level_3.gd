extends Node2D

@onready var heartsContainer = $CanvasLayer/Hearts
@onready var player = $player
@onready var pause_menu = $CanvasLayer2/PauseMenu

# Called when the node enters the scene tree for the first time.
func _ready():
	heartsContainer.setMaxHearts(player.max_health)
	heartsContainer.updateHearts(player.health)
	player.healthChanged.connect(heartsContainer.updateHearts)
	pause_menu.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
