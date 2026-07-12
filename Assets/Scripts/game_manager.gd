extends Node

var starting_area = 1
var current_area = 1
var area_path = "res://Assets/Scenes/Berreiche/"

var münze = 0
var tod = 0
var area_container : Node2D
var player : player
var hud : HUD
var loaded_area : Node2D
var player_start_position : Node2D



func _ready():
	hud = get_tree().get_first_node_in_group("hud")
	area_container = get_tree().get_first_node_in_group("area_container")
	player = get_tree().get_first_node_in_group("player")
	start_background_music()
	load_area(starting_area)
	hud.update_tod_label(tod)

func start_background_music() -> void:
	var audio_player = AudioStreamPlayer.new()
	audio_player.stream = create_background_stream()
	audio_player.autoplay = true
	audio_player.bus = "Master"
	audio_player.volume_db = -12.0
	audio_player.name = "BackgroundMusic"
	get_tree().root.add_child(audio_player)
	audio_player.play()

func create_background_stream() -> AudioStreamWAV:
	var stream = AudioStreamWAV.new()
	stream.mix_rate = 22050
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.stereo = false

	var duration = 2.0
	var sample_count = int(stream.mix_rate * duration)
	var data = PackedByteArray()

	for i in range(sample_count):
		var t = float(i) / stream.mix_rate
		var base = sin(2.0 * PI * 220.0 * t) * 0.25
		var harmony = sin(2.0 * PI * 330.0 * t) * 0.15
		var sample = int((base + harmony) * 12000.0)
		data.append(sample & 0xFF)
		data.append((sample >> 8) & 0xFF)

	stream.data = data
	return stream



	

func next_area():
	current_area += 1
	load_area(current_area)
	#set_up_bereich()



func load_area(area_number):
	
	# Checking the new scene path
	var full_path = area_path + "bereich_" + str(current_area) + ".tscn"
	#get_tree().change_scene_to_file(full_path)
	#print("The player has moved to area" + str(current_area))
	var scene = load(full_path) as PackedScene
	if !scene:
		return
	# Removing the previous scene
	for child in area_container.get_children():
		child.queue_free()
		await child.tree_exited
	# Setting up the new scene
	var instance = scene.instantiate()
	area_container.add_child(instance)
	loaded_area = instance
	reset_münze()
	# Moving the player to start position of the new scene
	player_start_position = get_tree().get_first_node_in_group("player_start_position") as Node2D
	player.teleport_to_location(player_start_position.position)
	




func add_münze():
	münze += 1
	hud.update_münze_label(münze)
	if münze >= 4:
		var portal = get_tree().get_first_node_in_group("area_exits") as AreaExit
		portal.open()
		hud.tür_opened()

func add_tod():
	tod += 1
	hud.update_tod_label(tod)

func reset_münze():
	münze = 0
	hud.update_münze_label(münze)
	hud.tür_closed()
