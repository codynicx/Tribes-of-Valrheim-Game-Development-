extends Button

@onready var camera_pivot = $"/root/GameBoard3D/CameraPivot"  # Adjust the path to your camera pivot node

# Called when the button is pressed
func _ready():
	# Connect the button press signal to the _on_Button_pressed method using Callable
	self.connect("pressed", Callable(self, "_on_Button_pressed"))

# Reset camera when the button is pressed
func _on_Button_pressed():
	print("Button Pressed - Resetting Camera")
	reset_camera()

# Function to reset the camera's rotation to the default value
func reset_camera():
	var default_rotation = Vector3(-45, 0, 0)  # Set your desired default rotation here
	var tween = get_tree().create_tween()
	tween.tween_property(camera_pivot, "rotation_degrees", default_rotation, 0.5)  # Adjusted tween call to fit Godot 4.x
