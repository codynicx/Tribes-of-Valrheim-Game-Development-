extends Node3D

@export var hex_scene: PackedScene
@export var number_token_scene: PackedScene
@export var sand: PackedScene
@export var city: PackedScene
@export var grid_radius: int = 2 # defines how large the hex grid will be

var hex_scale_factor: float = 1.5
var resource_types: Array = ["Stone", "Wood", "Wool", "Meat", "Wheat", "Iron"]
var resource_distribution: Dictionary = {
	"Stone": 3,
	"Wood": 4,
	"Wool": 4,
	"Meat": 3,
	"Wheat": 4,
	"Iron": 3
}
var resource_mesh_instances: Dictionary = {}
var used_numbers: Array = []
var hex_positions: Array = [] # Store positions of all hex tiles
var placed_city_positions: Dictionary = {}
var is_dragging = false

func setup(resource_meshes: Node) -> void:
	_load_resource_meshes(resource_meshes)
	_spawn_sand_background() 
	_generate_hex_grid()
	_place_yggdrasil()

func _load_resource_meshes(resource_meshes: Node) -> void:
	var all_resources: Array = resource_types + ["Yggdrasil"]
	for resource_name in all_resources:
		var mesh_instance: MeshInstance3D = resource_meshes.find_child(resource_name + "Mesh", true)
		if mesh_instance:
			resource_mesh_instances[resource_name] = mesh_instance.mesh

func _generate_hex_grid() -> void:
	var hex_width: float = 2.0 * hex_scale_factor
	var hex_height: float = sqrt(3) * hex_scale_factor
	var numbers: Array = [2, 3, 3, 4, 4, 5, 5, 5, 6, 6, 8, 8, 9, 9, 10, 10, 11, 12]

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
			var hex_position: Vector3 = Vector3(hex_width * (q + r * 0.5), 0.1, hex_height * r)
			_spawn_hex_tile(q, r, hex_position, resource_pool[i], numbers)
			hex_positions.append(hex_position)
			i += 1

# Function to spawn a hex tile
func _spawn_hex_tile(q: int, r: int, hex_position: Vector3, resource: String, numbers: Array) -> void:
	var hex_instance: Node3D = hex_scene.instantiate()
	hex_instance.position = hex_position
	hex_instance.scale = Vector3(hex_scale_factor, 2, hex_scale_factor)
	add_child(hex_instance)
	hex_instance.add_to_group("hexes")

	var mesh: Mesh = resource_mesh_instances.get(resource, null)
	if mesh:
		var mesh_instance: MeshInstance3D = MeshInstance3D.new()
		mesh_instance.mesh = mesh.duplicate(true)
		hex_instance.add_child(mesh_instance)

		# 🔧 Add collision shape to detect raycast clicks
		var body := StaticBody3D.new()
		var collider := CollisionShape3D.new()
		var shape := CylinderShape3D.new()
		shape.radius = 1.0 * hex_scale_factor
		shape.height = 1.0
		collider.shape = shape
		body.add_child(collider)
		body.position.y = 0.1  # Align with tile surface
		hex_instance.add_child(body)

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

func _place_yggdrasil() -> void:
	var yggdrasil_instance: Node3D = hex_scene.instantiate()
	yggdrasil_instance.position = Vector3(0, 0.2, 0)
	yggdrasil_instance.scale = Vector3(hex_scale_factor, 1, hex_scale_factor)
	add_child(yggdrasil_instance)

	var mesh: Mesh = resource_mesh_instances.get("Yggdrasil", null)
	if mesh:
		var mesh_instance: MeshInstance3D = MeshInstance3D.new()
		mesh_instance.mesh = mesh.duplicate(true)
		yggdrasil_instance.add_child(mesh_instance)

func _spawn_sand_background() -> void:
	var sand_instance: Node3D = sand.instantiate()
	sand_instance.scale = Vector3(20.2, 1, 17.5)
	sand_instance.position = Vector3(-0.8, 0.1, 12.6)
	add_child(sand_instance)

# New function to get hex tile edges for valid road placement
func get_hex_edges() -> Array:
	var edges: Array = []
	for pos in hex_positions:
		for i in range(6):
			var angle: float = float(i) * PI / 3.0
			var edge_pos: Vector3 = pos + Vector3(cos(angle) * hex_scale_factor, 0, sin(angle) * hex_scale_factor)
			edges.append(edge_pos)
	return edges

func spawn_cities():
	for hex in get_children():
		if not hex is Node3D:
			continue

		var hex_position = hex.position
		var hex_corners = _get_hex_corners(hex_position)

		for corner_position in hex_corners:
			var key = _snap_position(corner_position)
			if not placed_city_positions.has(key):
				placed_city_positions[key] = true

				var city_instance = city.instantiate()
				city_instance.position = corner_position
				add_child(city_instance)


func _get_hex_corners(center: Vector3) -> Array:
	var corners = []
	var radius = hex_scale_factor

	for i in range(6):
		var angle_deg = 60 * i - 30
		var angle_rad = deg_to_rad(angle_deg)
		var x = center.x + radius * cos(angle_rad)
		var z = center.z + radius * sin(angle_rad)
		corners.append(Vector3(x, 0.3, z))

	return corners

func _snap_position(pos: Vector3) -> String:
	var snapped_x = snapped(pos.x, 0.5)
	var snapped_z = snapped(pos.z, 0.9)
	return "%0.2f_%0.2f" % [snapped_x, snapped_z]
