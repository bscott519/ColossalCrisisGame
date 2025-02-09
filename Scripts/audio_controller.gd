extends Node2D

@export var mute: bool = false

func _ready():
	pass
	#if not mute:
		#playTitleMusic()
#func playTitleMusic():
	#if not mute:
		#$TitleMusic.play()
func playLevelMusic():
	if not mute:
		$LevelMusic.play()
func playJump():
	if not mute:
		$Jump.play()
