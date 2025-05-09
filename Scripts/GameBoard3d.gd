extends Node3D

@onready var hex_field = $HexField
@onready var resource_meshes = $ResourceMeshes
@onready var road_placer = $RoadPlacer

var placing_road = false

func _ready():
	# Setup the hex field
	hex_field.setup(resource_meshes)

func _on_road_pressed():
	placing_road = true
	if road_placer:
		road_placer.begin_road_placement()
		$City.visible = false

func _on_city_button_pressed() -> void:
	#hex_field.spawn_cities()
	$CityButton.visible = false
	$City.visible = true
