extends Node3D

@onready var hex_field = $HexField
@onready var resource_meshes = $ResourceMeshes

func _ready():
	hex_field.setup(resource_meshes)
