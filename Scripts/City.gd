extends Node3D

var draggable = false
var is_inside_dropable = false
var body_ref


func _on_area_3d_mouse_entered() -> void:
	if not HexField.is_dragging:
		draggable = true
		scale = Vector3(1.2, 1.2, 1.2)
		
func _on_area_3d_mouse_exited() -> void:
	if not HexField.is_dragging:
		draggable = false
		scale = Vector3(1, 1, 1)

func _on_area_3d_body_entered(body: Node3D) -> void:
	pass # Replace with function body.


func _on_area_3d_body_exited(body: Node3D) -> void:
	pass # Replace with function body.
