extends Control
var stashed_time_scale: float = 0.0
var pausesprite = preload("res://Sprites/Menu/PauseSpriteWithShading.png")
var playsprite = preload("res://Sprites/Menu/play button.png")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_pause_button_pressed() -> void:
	#freeze the gameplay
	Globals.is_frozen = not Globals.is_frozen
	#un/freeze explosion animation
	#CODE BELOW: 1. Finds whether frozen or not 2. Update all things [organ animation, pausebuttonsprite, pausescreen bg)
	var organnode = get_node("/root/Node2D/PlayerCharacter/PlayerSprite/Organs")    
	var pausebuttonspritenode = get_node("PauseButtonPadding/PauseButton/PauseSprite")
	var pausescreenbgnode = get_node("PauseMenu/PauseScreenBgContainer/PauseScreenBg")
	if Globals.is_frozen:
		organnode.pause_explosion()
		pausebuttonspritenode.texture = playsprite
		pausescreenbgnode.show()
	else:
		organnode.resume_explosion()
		pausebuttonspritenode.texture = pausesprite
		pausescreenbgnode.hide()
