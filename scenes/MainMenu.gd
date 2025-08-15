extends Control

@onready var gamePanel = $UILayer/WorldSelector
@onready var settingsPanel = $UILayer/SettingsMenu

func _on_play_pressed():
	print("Play pressed")
	#get_tree().change_scene_to_file("res://scenes/game.tscn")
	gamePanel.visible = true


func _on_options_pressed():
	print("Options pressed")
	settingsPanel.visible = true



func _on_exit_pressed():
	print("Exit pressed. byebye")
	get_tree().quit()
