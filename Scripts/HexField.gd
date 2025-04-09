extends Node3D

@export var hex_scene: PackedScene
@export var number_token_scene: PackedScene
@export var grid_radius: int = 2

var hex_scale_factor: float = 1.5

# Explicitly define the type for the resource types
var resource_types: Array = ["Stone", "Wood", "Wool", "Meat", "Wheat", "Iron"]
# Explicitly define the resource distribution dictionary
var resource_distribution: Dictionary = {
	"Stone": 3,
	"Wood": 4,
	"Wool": 4,
	"Meat": 3,
	"Wheat": 4,
	"Iron": 3
}
# Explicitly define types for mesh instances and used numbers
var resource_mesh_instances: Dictionary = {}
var used_numbers: Array = []

func setup(resource_meshes: Node) -> void:
	_load_resource_meshes(resource_meshes)
	_generate_hex_grid()
	_place_yggdrasil()

# Function to load resource meshes
func _load_resource_meshes(resource_meshes: Node) -> void:
	var all_resources: Array = resource_types + ["Yggdrasil"]
	for resource_name in all_resources:
		var mesh_instance: MeshInstance3D = resource_meshes.find_child(resource_name + "Mesh", true)
		if mesh_instance:
			resource_mesh_instances[resource_name] = mesh_instance.mesh

# Function to generate the hex grid
func _generate_hex_grid() -> void:
	var hex_width: float = 2.0 * hex_scale_factor
	var hex_height: float = sqrt(3) * hex_scale_factor
	var numbers: Array = [2, 3, 3, 4, 4, 5, 5, 5, 6, 6, 8, 8, 9, 9, 10, 10, 11, 12]

	# Prepare balanced resource list
	var resource_pool: Array = []
	for resource_name in resource_distribution.keys():
		var count: int = resource_distribution[resource_name]
		for i in range(count):
			resource_pool.append(resource_name)

	resource_pool.shuffle()

	var i: int = 0
	for q in range(-grid_radius, grid_radius + 1):
		for r in range(-grid_radius, grid_radius + 1):
			if abs(q + r) > grid_radius or (q == 0 and r == 0):
				continue

			var hex_position: Vector3 = Vector3(hex_width * (q + r * 0.5), 0, hex_height * r)  # Renamed to hex_position
			_spawn_hex_tile(hex_position, resource_pool[i], numbers)
			i += 1

# Function to spawn a hex tile
func _spawn_hex_tile(hex_position: Vector3, resource: String, numbers: Array) -> void:  # Renamed to hex_position
	var hex_instance: Node3D = hex_scene.instantiate()
	hex_instance.position = hex_position
	hex_instance.scale = Vector3(hex_scale_factor, 1, hex_scale_factor)
	add_child(hex_instance)

	# Add resource mesh
	var mesh: Mesh = resource_mesh_instances.get(resource, null)
	if mesh:
		var mesh_instance: MeshInstance3D = MeshInstance3D.new()
		mesh_instance.mesh = mesh.duplicate(true)
		hex_instance.add_child(mesh_instance)

	# Add number token
	if numbers.size() > 0:
		var number: int = numbers.pick_random()
		numbers.erase(number)
		used_numbers.append(number)

		var token: Node3D = number_token_scene.instantiate()
		token.number = number
		token.position = Vector3(0, 0.1, 0)
		hex_instance.add_child(token)

		var label: Label3D = token.get_node_or_null("Label3D")
		if label:
			label.text = str(number)

# Function to place Yggdrasil at the center of the grid
func _place_yggdrasil() -> void:
	var yggdrasil_instance: Node3D = hex_scene.instantiate()
	yggdrasil_instance.position = Vector3.ZERO
	yggdrasil_instance.scale = Vector3(hex_scale_factor, 1, hex_scale_factor)
	add_child(yggdrasil_instance)

	var mesh: Mesh = resource_mesh_instances.get("Yggdrasil", null)
	if mesh:
		var mesh_instance: MeshInstance3D = MeshInstance3D.new()
		mesh_instance.mesh = mesh.duplicate(true)
		yggdrasil_instance.add_child(mesh_instance)
