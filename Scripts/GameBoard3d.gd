extends Node3D

@onready var hex_field = $HexField
@onready var resource_meshes = $ResourceMeshes

var is_dragging = false;

func _ready():
	hex_field.setup(resource_meshes)
	$City.visible = false

func _on_city_button_pressed() -> void:
	#hex_field.spawn_cities()
	$CityButton.visible = false
	$City.visible = true
