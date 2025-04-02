extends Node3D

@export var hex_scene: PackedScene
@export var grid_radius: int = 2
@export var number_token_scene: PackedScene  # Add reference to the number token scene
@onready var resource_meshes = $ResourceMeshes

var rotate_speed : float = 0.5
var camera_pivot : Node3D
var rotating_camera : bool = false
var last_mouse_pos : Vector2

var resource_types = ["Stone", "Wood", "Wool", "Meat", "Wheat", "Iron"]
var resource_mesh_instances = {}

var hex_scale_factor : float = 1.5
var min_pitch : float = -30
var max_pitch : float = -60
var default_camera_rotation : Vector3

# Array to store used number tokens
var used_numbers = []  # Declare this variable outside any function

func _ready():
	# Initialize resource meshes
	for resource in resource_types + ["Yggdrasil"]:
		var mesh_instance = resource_meshes.find_child(resource + "Mesh", true)
		if mesh_instance:
			resource_mesh_instances[resource] = mesh_instance.mesh

	# Set up the grid, Yggdrasil, and camera pivot
	generate_hex_grid()
	place_yggdrasil()
	camera_pivot = $CameraPivot
	default_camera_rotation = camera_pivot.rotation_degrees

# Handle the input event (specifically for the "R" key)
func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_R:
		reset_camera()

# Reset the camera position using a tween
func reset_camera():
	var tween = get_tree().create_tween()
	print("Resetting camera rotation...")  # Log to ensure this function is called
	tween.tween_property(camera_pivot, "rotation_degrees", default_camera_rotation, 0.5)

# Generate hex grid with resources and number tokens
func generate_hex_grid():
	var hex_width = 2.0 * hex_scale_factor
	var hex_height = sqrt(3) * hex_scale_factor
	var numbers = [2, 3, 3, 4, 4, 5, 5, 5, 6, 6, 8, 8, 9, 9, 10, 10, 11, 12]  # Your custom number values

	for q in range(-grid_radius, grid_radius + 1):
		for r in range(-grid_radius, grid_radius + 1):
			if abs(q + r) > grid_radius or (q == 0 and r == 0):
				continue

			var new_hex = hex_scene.instantiate()
			new_hex.position = Vector3(hex_width * (q + r * 0.5), 0, hex_height * r)
			new_hex.scale = Vector3(hex_scale_factor, 1, hex_scale_factor)
			add_child(new_hex)

			# Add random resource mesh
			var resource = resource_types.pick_random()
			var mesh = resource_mesh_instances.get(resource)
			if mesh:
				var new_mesh_instance = MeshInstance3D.new()
				new_mesh_instance.mesh = mesh.duplicate(true)
				new_hex.add_child(new_mesh_instance)

			# Place a number token on the tile, ensuring no duplicates
			if numbers.size() > 0:
				var num_token = number_token_scene.instantiate()
				var random_number = numbers.pick_random()
				used_numbers.append(random_number)  # Add number to used numbers
				numbers.erase(random_number)  # Remove the number from the pool

				num_token.number = random_number  # Set the number
				num_token.position = Vector3(0, 0.1, 0)  # Adjust height to place on top of hex
				new_hex.add_child(num_token)

				# Set the number text on the Label3D
				num_token.get_node("Label3D").text = str(random_number)

# Place Yggdrasil at the center
func place_yggdrasil():
	var yggdrasil_hex = hex_scene.instantiate()
	yggdrasil_hex.position = Vector3(0, 0, 0)
	yggdrasil_hex.scale = Vector3(hex_scale_factor, 1, hex_scale_factor)
	add_child(yggdrasil_hex)
	var mesh = resource_mesh_instances.get("Yggdrasil")
	if mesh:
		var yggdrasil_mesh_instance = MeshInstance3D.new()
		yggdrasil_mesh_instance.mesh = mesh.duplicate(true)
		yggdrasil_hex.add_child(yggdrasil_mesh_instance)
