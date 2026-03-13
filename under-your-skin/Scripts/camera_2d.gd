extends Camera2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	zoom.x = Globals.game_zoom
	zoom.y = Globals.game_zoom
func update_zoom():
	zoom.x = Globals.game_zoom
	zoom.y = Globals.game_zoom

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
