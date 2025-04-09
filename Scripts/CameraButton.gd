extends Button

@onready var camera_pivot: Node3D = $"/root/GameBoard3D/CameraPivot"  # Adjust if needed

var default_rotation: Vector3 = Vector3(-45, 0, 0)
var previous_rotation: Vector3 = Vector3.ZERO
var is_default_view: bool = false

func _ready():
	self.connect("pressed", Callable(self, "_on_Button_pressed"))
	previous_rotation = camera_pivot.rotation_degrees  # Store initial rotation

func _on_Button_pressed():
	print("Button Pressed - Toggling Camera")
	toggle_camera()

func toggle_camera():
	var tween = get_tree().create_tween()

	if is_default_view:
		# Go back to previous rotation
		tween.tween_property(camera_pivot, "rotation_degrees", previous_rotation, 0.5)
	else:
		# Store current rotation before resetting
		previous_rotation = camera_pivot.rotation_degrees
		tween.tween_property(camera_pivot, "rotation_degrees", default_rotation, 0.5)

	is_default_view = !is_default_view  # Toggle state
