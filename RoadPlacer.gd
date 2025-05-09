extends Node3D

@export var road_scene: PackedScene  # Drag your Road3D scene here in the Inspector
var placed_road: Node3D = null

var is_dragging: bool = false
var camera: Camera3D

# Distance threshold for snapping
const SNAP_THRESHOLD := 2.0

func _ready():
	camera = get_viewport().get_camera_3d()
	_place_road_outside_grid()

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if !placed_road:
			var world_pos = _get_mouse_world_position(event.position)
			if world_pos:
				_place_road_at_position(world_pos)
		else:
			is_dragging = !is_dragging
			if !is_dragging:
				_snap_to_nearest_midpoint()

	elif event is InputEventMouseMotion and is_dragging:
		var world_pos = _get_mouse_world_position(event.position)
		if world_pos and placed_road:
			placed_road.global_position = world_pos

func _place_road_outside_grid():
	if road_scene:
		placed_road = road_scene.instantiate()
		add_child(placed_road)
		placed_road.global_position = Vector3(0, 0.2, -5)
	else:
		push_error("Road scene is not assigned.")

func _place_road_at_position(position: Vector3):
	if road_scene:
		if not placed_road:
			placed_road = road_scene.instantiate()
			add_child(placed_road)
		placed_road.global_position = position
	else:
		push_error("Road scene is not assigned.")

func _get_mouse_world_position(screen_pos: Vector2) -> Vector3:
	var from = camera.project_ray_origin(screen_pos)
	var to = from + camera.project_ray_normal(screen_pos) * 1000

	var query = PhysicsRayQueryParameters3D.new()
	query.from = from
	query.to = to
	query.collide_with_areas = true
	query.collide_with_bodies = true

	var space_state = get_world_3d().direct_space_state
	var result = space_state.intersect_ray(query)

	if result:
		return result.position
	return null

func _snap_to_nearest_midpoint():
	var nearest_pair = _find_nearest_hex_pair()
	if nearest_pair.size() == 2:
		var midpoint = (nearest_pair[0].global_position + nearest_pair[1].global_position) * 0.5
		placed_road.global_position = midpoint
		placed_road.look_at(nearest_pair[1].global_position, Vector3.UP)

func _find_nearest_hex_pair() -> Array:
	var closest_pair = []
	var closest_distance = INF

	var hexes = get_tree().get_nodes_in_group("hexes")

	for i in range(hexes.size()):
		for j in range(i + 1, hexes.size()):
			var a = hexes[i]
			var b = hexes[j]
			var mid = (a.global_position + b.global_position) * 0.5
			var dist = placed_road.global_position.distance_to(mid)

			if dist < SNAP_THRESHOLD and dist < closest_distance:
				closest_distance = dist
				closest_pair = [a, b]

	return closest_pair
