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
	visible = false
	can_control = false
	
	await get_tree().create_timer(1).timeout
	reset_player()
	

func reset_player() -> void:
	global_position = GameManager.loaded_area.area_container.global_position
	visible = true
	can_control = true
