extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Globals.lights_on == false:
		hide()
func update_lighting():
	if Globals.lights_on == false:
		hide()
	else:
		show()
	print("got func")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
