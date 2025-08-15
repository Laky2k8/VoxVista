extends Control

@onready var pause_menu_container = $PauseMenuContainer

func _process(delta):
	if Input.is_action_just_pressed("pause"):
		pause_menu_container.visible = not pause_menu_container.visible
		Global.paused = pause_menu_container.visible
		

			


func _on_resume_pressed():
	pause_menu_container.visible = false
	Global.paused = false


func _on_quit_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
