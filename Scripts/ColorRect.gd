extends ColorRect

func _ready():
	adjust_size()
	get_viewport().size_changed.connect(adjust_size)  # Adjust when screen resizes

func adjust_size():
	size = get_viewport_rect().size  # Get the actual viewport size
