extends Area2D
class_name AreaExit

@export var sprite : Sprite2D

var is_open = false

func _ready():
	close()

func open():
	is_open = true

func close():
	is_open = false



func _on_body_entered(body):
	if is_open &&  body is player :
		GameManager.next_area()
