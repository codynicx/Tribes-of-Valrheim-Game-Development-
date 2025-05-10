extends Area3D

var quantity: int = 5 
@onready var label_3d = $Label3D 
 
func _ready():
	label_3d.billboard = BaseMaterial3D.BILLBOARD_ENABLED #face camera at all times
	update_label()
 
func _on_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			quantity -= 1
			update_label()
			if quantity <= 0:
				queue_free()

func update_label():
	label_3d.text = str(quantity)

func _process(delta):
	if get_viewport().get_camera_3d():
		label_3d.look_at(get_viewport().get_camera_3d().global_transform.origin, Vector3.UP)

