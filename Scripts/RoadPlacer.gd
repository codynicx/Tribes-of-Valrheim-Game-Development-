extends Node3D

# This is the reference to the road scene that we want to place on the map (we can drag it into the Inspector).
@export var road_scene: PackedScene

# This is the path to the HexField node that will manage our hex tiles.
@export var hex_field_path: NodePath = "../HexField"

# We store a reference to the HexField node here after we fetch it in _ready().
var hex_field: Node = null
var camera: Camera3D

# This is a flag we use to control whether we're in the "road placing mode" or not.
var placing := false

# These are the six directions around a hexagon (assuming pointy-topped) where we can place roads.
var hex_edges = [
	Vector3(1, 0, 0),              # Right
	Vector3(0.5, 0, -sqrt(3)/2),   # Upper-right
	Vector3(-0.5, 0, -sqrt(3)/2),  # Upper-left
	Vector3(-1, 0, 0),             # Left
	Vector3(-0.5, 0, sqrt(3)/2),   # Lower-left
	Vector3(0.5, 0, sqrt(3)/2)     # Lower-right
]

# This is how much we offset the road's vertical position. It helps place the road at the right height.
@export var road_height_offset: float = -0.01

# This function is called when the node is ready (loaded and added to the scene).
func _ready():
	# We get the HexField node from the path we set earlier.
	hex_field = get_node_or_null(hex_field_path)
	if not hex_field:
		push_error("HexField node not found at path: %s" % hex_field_path)

	# We get the active camera from the scene for raycasting.
	camera = get_viewport().get_camera_3d()

# This function is triggered when we want to start placing roads.
func begin_road_placement():
	placing = true

# This function listens for user input. If the user clicks, we attempt to place a road.
func _input(event):
	if not placing:
		return

	# If the user clicks the left mouse button, we try to place a road.
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_place_road_at_mouse(event.position)
		placing = false

# This function places the road where the mouse clicked, based on raycasting.
func _place_road_at_mouse(mouse_pos: Vector2):
	# We cast a ray from the mouse position into the scene.
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * 50.0

	# We create the ray query parameters to check for collisions.
	var query = PhysicsRayQueryParameters3D.new()
	query.from = from
	query.to = to
	query.collide_with_areas = true
	query.collide_with_bodies = true

	# We perform the raycast to get the position where the ray hits something.
	var result = get_world_3d().direct_space_state.intersect_ray(query)
	if result:
		# If the ray hit something, we get the position and spawn the road there.
		var world_pos = result.position
		_spawn_road(world_pos)

# This function handles spawning the road at a specific position.
func _spawn_road(at_pos: Vector3):
	# First, we check if we have a road scene to instantiate.
	if not road_scene:
		push_error("No road scene assigned!")
		return

	# We create an instance of the road scene.
	var road_instance = road_scene.instantiate()
	add_child(road_instance)

	# We find the "RoadMesh" inside the road scene.
	var road_mesh_node = road_instance.get_node("StaticBody3D/RoadMesh")
	if not road_mesh_node:
		push_error("RoadMesh node not found in the road scene!")
		return

	# We set the position of the road instance, adjusting for the height offset.
	road_instance.global_position = at_pos
	road_instance.global_position.y += road_height_offset

	# We now determine the closest edge of the hex that the road should be placed on.
	var edge_index = _get_closest_hex_edge(at_pos)
	var edge_direction = hex_edges[edge_index]

	# We align the road mesh with the chosen edge.
	road_mesh_node.look_at(at_pos + edge_direction, Vector3.UP)

# This function determines the closest edge to the clicked position.
func _get_closest_hex_edge(_at_pos: Vector3) -> int:
	# For now, we just pick a random edge (this will be changed to align with the grid logic later).
	return int(randf_range(0, 6))  # Pick a random edge (0–5)
