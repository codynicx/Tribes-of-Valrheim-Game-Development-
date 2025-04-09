extends Node3D

@export var number: int
@onready var label = $Label  # Ensure this is the correct path to the Label node

func _ready():
	# Ensure the label node is found before setting the text
	if label != null:
		label.text = str(number)
	else:
		push_error("Label node not found in NumberToken scene!")
