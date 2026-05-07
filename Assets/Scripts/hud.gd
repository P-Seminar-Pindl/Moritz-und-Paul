extends Control
class_name HUD

@export var münze_label : Label
@export var tür_label : Label

func update_münze_label(number : int):
	münze_label.text = "X " + str(number)

func _opened():
	
