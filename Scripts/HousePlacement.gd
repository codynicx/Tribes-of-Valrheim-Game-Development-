extends Node2D

@export var game_board: Node2D  # ✅ Reference to GameBoard
@export var house_scene: PackedScene  # ✅ Reference to House scene (preloaded prefab)

var houses = []  # ✅ Store placed Houses
var valid_positions = []  # ✅ Store valid placement positions

func _ready():
	_update_valid_positions()  # ✅ Calculate where Houses can be placed

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		var clicked_pos = get_global_mouse_position()  # ✅ Get mouse position
		var hex_pos = game_board.tile_map.local_to_map(clicked_pos)  # ✅ Convert to hex tile position
		
		if _is_valid_placement(hex_pos):  # ✅ Check if placement is valid
			_place_house(hex_pos)  # ✅ Place House if valid

func _place_house(hex_pos):
	var house = house_scene.instantiate()  # ✅ Create House instance
	house.position = game_board.tile_map.map_to_local(hex_pos)  # ✅ Set position to hex tile
	add_child(house)  # ✅ Add House to scene
	houses.append(hex_pos)  # ✅ Store placed House position

	_update_valid_positions()  # ✅ Update valid positions after placement

func _is_valid_placement(hex_pos) -> bool:
	# ✅ 1. Check if already occupied
	if hex_pos in houses:
		return false

	# ✅ 2. Check Catan-like distance rule (House cannot be adjacent to another)
	for house in houses:
		if _are_adjacent(house, hex_pos):  # ✅ Check if too close to another House
			return false

	# ✅ 3. (Optional) Ensure it's connected to a player's Street (to be implemented later)

	return true  # ✅ Placement is valid

func _are_adjacent(pos1, pos2) -> bool:
	# ✅ Define hex corner adjacency rules
	var adjacent_positions = [
		Vector2(pos1.x + 1, pos1.y),
		Vector2(pos1.x - 1, pos1.y),
		Vector2(pos1.x, pos1.y + 1),
		Vector2(pos1.x, pos1.y - 1)
	]
	return pos2 in adjacent_positions  # ✅ Return if positions are adjacent

func _update_valid_positions():
	# ✅ Placeholder: Calculate valid intersections for House placement
	valid_positions.clear()
	var hex_tiles = game_board.tile_map.get_used_cells(0)  # ✅ Get hex tiles
	for tile in hex_tiles:
		valid_positions.append(tile)  # ✅ Add tile as a possible placement position
