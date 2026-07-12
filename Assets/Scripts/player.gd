extends CharacterBody2D
class_name player
@export var speed = 10.0
@export var jump_power = 10.0
@export var camera : Camera2D

var speed_multiplier = 30.0
var jump_multiplier = -30.0
var direction = 0
var can_control : bool = true

#const SPEED = 300.0
#const JUMP_VELOCITY = -400.0


var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")





func _physics_process(delta):
	if not can_control: return
	
	# Add the gravity.
	if not is_on_floor():
		
		velocity.y += gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_power*jump_multiplier
		play_sound("jump")

	#Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	direction= Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * speed * speed_multiplier
	else:
		velocity.x = move_toward(velocity.x, 0, speed * speed_multiplier)

	move_and_slide()

func teleport_to_location(new_location):
	camera.position_smoothing_enabled = false
	global_position = new_location
	await get_tree().physics_frame
	camera.position_smoothing_enabled = true

func handle_danger() -> void:
	print("Player Died!")
	play_sound("death")
	visible = false
	can_control = false
	
	GameManager.add_tod()
	await get_tree().create_timer(1).timeout
	reset_player()
	

func reset_player() -> void:
	global_position = GameManager.player_start_position.global_position
	visible = true
	can_control = true

func play_sound(sound_type: String) -> void:
	var audio_player = AudioStreamPlayer.new()
	audio_player.stream = create_sound_stream(sound_type)
	get_tree().root.add_child(audio_player)
	audio_player.play()
	audio_player.finished.connect(audio_player.queue_free)

func create_sound_stream(sound_type: String) -> AudioStreamWAV:
	var stream = AudioStreamWAV.new()
	stream.mix_rate = 22050
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.stereo = false

	var duration: float
	var frequency: float
	var volume: float
	var waveform: String

	match sound_type:
		"jump":
			duration = 0.18
			frequency = 820.0
			volume = 0.16
			waveform = "sine"
		"death":
			duration = 0.35
			frequency = 220.0
			volume = 0.18
			waveform = "triangle"
		_: 
			duration = 0.12
			frequency = 880.0
			volume = 0.22
			waveform = "sine"

	var sample_count = int(stream.mix_rate * duration)
	var data = PackedByteArray()

	for i in range(sample_count):
		var t = float(i) / stream.mix_rate
		var value: float = 0.0
		match waveform:
			"sine":
				value = sin(2.0 * PI * frequency * t)
			"triangle":
				value = 2.0 * abs(2.0 * (t * frequency - floor(t * frequency + 0.5))) - 1.0
			"square":
				value = 1.0 if sin(2.0 * PI * frequency * t) >= 0.0 else -1.0
		var sample = int(value * volume * 32767.0)
		data.append(sample & 0xFF)
		data.append((sample >> 8) & 0xFF)

	stream.data = data
	return stream
