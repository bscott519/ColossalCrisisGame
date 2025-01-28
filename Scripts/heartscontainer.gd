extends HBoxContainer

@onready var heartGUIClass = preload("res://Scenes/heartgui.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func setMaxHearts(max: int):
	for i in range(max):
		var heart = heartGUIClass.instantiate()
		add_child(heart)

func updateHearts(curHealth: int):
	var hearts = get_children()
	
	for i in range(curHealth):
		hearts[i].update(true)
	
	for i in range(curHealth, hearts.size()):
		hearts[i].update(false)
