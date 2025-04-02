extends TileMap  # ✅ TileMap script

var resource_types = {
	2: "Iron",
	3: "Stone",
	4: "Wood",
	5: "Wool",
	6: "Meat",
	7: "Wheat"
}

@onready var background = $"../Background"  # ✅ Reference to the background

func _ready():
	update_tilemap()
	background.get_viewport().size_changed.connect(update_tilemap)  # ✅ Adjust when resized

func assign_resources_and_numbers(hex_tiles: Array, number_values: Array) -> Dictionary:
	var tile_data = {}  # ✅ Store assigned resources & numbers
	var available_resources = resource_types.keys()
	available_resources.shuffle()  # ✅ Shuffle resources randomly
	number_values.shuffle()  # ✅ Shuffle number values randomly

	var assigned_tiles = {}  # ✅ Dictionary to track assigned resource tiles

	# ✅ Assign resources while identifying the desert tile
	for tile_pos in hex_tiles:
		var tile_id = get_cell_source_id(0, tile_pos)  # ✅ Get the tile ID from TileMap
		if tile_id == 1:  
			continue  # ✅ Skip assigning resource to the desert tile

		var resource_id = available_resources[assigned_tiles.size() % available_resources.size()]
		assigned_tiles[tile_pos] = resource_types[resource_id]  # ✅ Assign resource

	# ✅ Assign number tokens (only to resource tiles, skipping the yssagril tile)
	var tiles_with_numbers = assigned_tiles.keys()
	tiles_with_numbers.shuffle()  # ✅ Shuffle order

	for i in range(len(number_values)):  
		var tile_pos = tiles_with_numbers[i]
		var number_value = number_values[i]

		# ✅ Store assigned resource & number
		tile_data[tile_pos] = {
			"resource": assigned_tiles[tile_pos],  # ✅ Resource type
			"number": number_value  # ✅ Assigned number
		}

		# ✅ Place number token **on TileMap**
		place_number_token(tile_pos, number_value)

	return tile_data  # ✅ Return assigned data

func place_number_token(tile_pos, number_value):
	var token_scene = preload("res://Scenes/number_token.tscn").instantiate()
	token_scene.position = map_to_local(tile_pos)  # ✅ Attach to correct tile position
	token_scene.get_node("NumberLabel").text = str(number_value)  # ✅ Assign the number
	add_child(token_scene)  # ✅ Attach **directly to TileMap**

func update_tilemap():
	# ✅ Get viewport size (window size)
	var viewport_size = get_viewport_rect().size  

	# ✅ Get the used TileMap area
	var used_rect = get_used_rect()
	var tile_size = Vector2(tile_set.tile_size)  # ✅ Convert Vector2i → Vector2
	var tilemap_size = Vector2(used_rect.size) * tile_size  # ✅ Multiplication now valid
	var tilemap_offset = Vector2(used_rect.position) * tile_size

	# ✅ Calculate scale factor to fit within the viewport
	var base_tile_size = 100  # Increased for better visibility on small screens
	var scale_factor = min(viewport_size.x / (tilemap_size.x + base_tile_size), 
						   viewport_size.y / (tilemap_size.y + base_tile_size))
	scale_factor = clamp(scale_factor, 0.6, 1.2)  # ✅ Prevents over-shrinking & over-scaling
	scale = Vector2(scale_factor, scale_factor)

	# ✅ Adjust position to perfectly center the TileMap
	var scaled_tilemap_size = tilemap_size * scale
	var scaled_offset = tilemap_offset * scale * 0.80  # ✅ Adjusted offset to fit tiles in view
	position = (viewport_size - scaled_tilemap_size) / 2 - scaled_offset + Vector2(5, 5)  # ✅ Fine-tuned for small screens
