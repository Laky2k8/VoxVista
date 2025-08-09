extends Control


func _on_play_pressed():
	print("Play pressed")
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_options_pressed():
	print("Options pressed")



func _on_exit_pressed():
	print("Exit pressed. byebye")
	get_tree().quit()
