extends Control
var stashed_time_scale: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_pause_button_pressed() -> void:

	if Globals.current_time_scale == 0:
		Globals.current_time_scale = stashed_time_scale
	else:
		stashed_time_scale = Globals.current_time_scale
		Globals.current_time_scale = 0
