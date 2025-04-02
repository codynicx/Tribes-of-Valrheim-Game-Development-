extends Node2D

@onready var tile_map = $TileMap  # ✅ Reference to TileMap
@onready var resource_manager = preload("res://Scripts/ResourceManager.gd").new()  # ✅ Load ResourceManager script

var number_values = [2, 3, 3, 4, 4, 5, 5, 5, 6, 6, 8, 8, 9, 9, 10, 10, 11, 12]  


func _ready():
	randomize()  # ✅ Ensure randomness
	var hex_tiles = tile_map.get_used_cells(0)  # ✅ Get all hex tiles from layer 0

	# ✅ Assign resources & numbers (Remove the extra argument)
	var _assigned_data = tile_map.assign_resources_and_numbers(hex_tiles, number_values)
