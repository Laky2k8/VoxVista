extends VBoxContainer

@onready var world_selector_panel = $"."

@onready var savefile_list: ItemList = $Panel/Worlds
@onready var load_button: Button = $Panel/Load

@onready var new_world: TextureButton = $Panel/NewWorld
@onready var name_input: LineEdit = $Panel/WorldName
@onready var seed_input: SpinBox = $Panel/Seed

const SAVE_DIR := "user://worlds"

func _on_exit_pressed():
	world_selector_panel.visible = false

func _ready():
	ensure_save_dir()
	refresh_savefile_list()
	
	load_button.disabled = true
	
	
	
func ensure_save_dir():
	var dir = DirAccess.open("user://")
	if not dir.dir_exists("worlds"):
		print("Worlds folder does not exist, creating one")
		dir.make_dir("worlds")
	
func refresh_savefile_list():
	savefile_list.clear()
	print("Populating list of savefiles")
	var dir = DirAccess.open(SAVE_DIR)
	
	if dir:
		print("Directory found!")
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				# Check if the file is an MP3 file
				if file_name.get_file().ends_with(".db"):
					print("Found world file: " + file_name)
					var world_name = file_name.get_basename()
					savefile_list.add_item(world_name)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
	'''print("Save dir opened")
	var file_name = dir.get_next()
	print("First filename: " + file_name)
	while file_name:
		print("Checking file...")
		if file_name.ends_with(".db"):
			var world_name = file_name.get_basename()
			print(world_name)
			savefile_list.add_item(world_name)
		print("Not worldfile")
		file_name = dir.get_next()'''

func _on_savefile_selected(savefile_number):
	print("Selected savefile " + str(savefile_number))
	load_button.disabled = false
	
func _load_world():
	var selected = savefile_list.get_item_text(savefile_list.get_selected_items()[0])
	Global.pending_world_name = selected
	Global.pending_seed = -1
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _new_world_creation():
	var name = name_input.text.strip_edges()
	if name == "":
		return
	Global.pending_world_name = name
	Global.pending_seed = seed_input.value
	get_tree().change_scene_to_file("res://scenes/game.tscn")
