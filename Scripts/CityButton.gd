extends Button

@onready var target_node = $City

func _ready():
	self.connect("pressed", Callable(self, "_on_Button_pressed"))

func _on_Button_pressed():
	if target_node.visible:
		target_node.hide()
	else:
		target_node.show()
