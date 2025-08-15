class_name SaveManager
extends Node

# TO SAVE THE WORLDS, THERE IS ONLY ONE WAY.
# THE SAVEMANAGER CLASS MUST BE ADDED TO THE WORLD NODE.
# ONLY THEN, WILL THE WORLDS BE SAVED.
# - John Deltarune, 2025

@onready var terrain: VoxelTerrain = get_parent().get_node("VoxelTerrain")

var save_directory: String = "user://worlds/"
var current_world_name: String = "default_world"
var created_time = Time.get_unix_time_from_system()

func _ready():
	ensure_save_directory()
	setup_stream()

func ensure_save_directory():
	print("Ensuring save directory exists...")
	var dir = DirAccess.open("user://")
	if not dir.dir_exists("worlds"):
		dir.make_dir("worlds")

func setup_stream():
	print("Setting up world...")
	var stream = VoxelStreamSQLite.new()
	stream.database_path = save_directory + current_world_name + ".db"
	terrain.stream = stream

func save_world():
	print("Saving world: ", current_world_name)
	terrain.save_modified_blocks()
	save_world_metadata() # Save seed

func load_world(world_name: String):
	current_world_name = world_name
	load_world_metadata() # Load seed and generate rest of world
	setup_stream() # Load modified chunks
	print("Loaded world: ", world_name)

func create_new_world(world_name: String, seed: int):
	current_world_name = world_name
	get_parent().seed = seed
	get_parent().regenerate_with_seed(seed)
	setup_stream()
	save_world_metadata() # Save seed right here right now
	created_time = Time.get_unix_time_from_system()
	print("Created new world: ", world_name, " with seed: ", seed)

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_world()

# WORLD METADATA SAVING/LOADING
func save_world_metadata():
	var metadata = {
		"seed": get_parent().seed,
		"world_name": current_world_name,
		"created_time": created_time,
		"last_modified": Time.get_unix_time_from_system()
	}
	
	
	var metadata_path = save_directory + current_world_name + "_metadata.json"
	var file = FileAccess.open(metadata_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(metadata))
		file.close()
	else:
		push_warning("Could not save world metadata!")
		
func load_world_metadata():
	var metadata_path = save_directory + current_world_name + "_metadata.json"
	var file = FileAccess.open(metadata_path, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		
		if parse_result == OK:
			var metadata = json.data
			
			if metadata.has("seed"):
				get_parent().seed = metadata["seed"]
				
				get_parent().regenerate_with_seed(metadata["seed"])
				
				print("Loaded metadata for world: ", current_world_name)
			
		else:
			push_warning("Parsing metadata file failed! World file could be corrupted!")
	else:
		push_warning("Could not load world metadata!")
