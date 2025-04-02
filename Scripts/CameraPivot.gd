extends Node3D

@export var rotate_speed : float = 0.5  # Rotation speed

var camera_pivot : Node3D
var rotating_camera : bool = false
var last_mouse_pos : Vector2

func _ready():
	# Use get_node to find CameraPivot node
	camera_pivot = get_node("CameraPivot")  # Adjusted path

func _input(event):
	if event is InputEventMouseButton:
		# Detect right mouse button press (for PC)
		if event.button_index == MOUSE_BUTTON_RIGHT:
			rotating_camera = event.pressed
			if event.pressed:
				last_mouse_pos = event.position
	
	elif event is InputEventScreenTouch:
		# Detect screen touch (for mobile)
		rotating_camera = event.pressed
		if event.pressed:
			last_mouse_pos = event.position

	elif event is InputEventMouseMotion and rotating_camera:
		# Handle mouse drag (for PC)
		var delta = event.position - last_mouse_pos
		camera_pivot.rotation_degrees.y -= delta.x * rotate_speed
		camera_pivot.rotation_degrees.x -= delta.y * rotate_speed
		last_mouse_pos = event.position

	elif event is InputEventScreenDrag and rotating_camera:
		# Handle touch drag (for mobile)
		var delta = event.position - last_mouse_pos
		camera_pivot.rotation_degrees.y -= delta.x * rotate_speed
		camera_pivot.rotation_degrees.x -= delta.y * rotate_speed
		last_mouse_pos = event.position
