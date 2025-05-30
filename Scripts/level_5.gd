extends Node2D

@onready var heartsContainer = $CanvasLayer/Hearts
@onready var player = $player
@onready var pause_menu = $CanvasLayer2/PauseMenu

# Called when the node enters the scene tree for the first time.
func _ready():
	$LevelTheme.play()
	$LevelTheme.finished.connect(_on_level_theme_finished)
	heartsContainer.setMaxHearts(player.max_health)
	heartsContainer.updateHearts(player.health)
	player.healthChanged.connect(heartsContainer.updateHearts)
	pause_menu.hide()
	
	var boss = $EarthGiant
	var door1 = $BossDoor
	var door2 = $BossDoor2
	
	boss.boss_died.connect(door1.open_doors)
	boss.boss_died.connect(door2.open_doors)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_level_theme_finished():
	$LevelTheme.play()
