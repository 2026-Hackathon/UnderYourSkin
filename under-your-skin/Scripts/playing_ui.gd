extends Control
var stashed_time_scale: float = 0.0
var pausesprite = preload("res://Sprites/Menu/PauseSpriteWithShading.png")
var playsprite = preload("res://Sprites/Menu/play button.png")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$"PauseMenuList/ZoomControlContainer/Zoom Slider".value = (Globals.game_zoom -1) * 25
		#update text
	if Globals.lights_on == false:
		$PauseMenuList/LightingButton.text = "Lighting: Off"
	else:
		$PauseMenuList/LightingButton.text = "Lighting: On"
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
	var movementcontrolbuttonnode = get_node("PauseMenuList/MovementControlPadding/MovementControlButton2")
	var zoomtxtnode = get_node("PauseMenuList/ZoomControlContainer/ZoomTxt")
	var zoomslidernode = get_node("PauseMenuList/ZoomControlContainer/Zoom Slider")
	var lightingbuttonnode = get_node("PauseMenuList/LightingButton")
	
	if Globals.is_frozen:
		organnode.pause_explosion()
		pausebuttonspritenode.texture = playsprite
		pausescreenbgnode.show()
		movementcontrolbuttonnode.show()
		zoomtxtnode.show()
		zoomslidernode.show()
		lightingbuttonnode.show()
	else:
		organnode.resume_explosion()
		pausebuttonspritenode.texture = pausesprite
		pausescreenbgnode.hide()
		movementcontrolbuttonnode.hide()
		zoomtxtnode.hide()
		zoomslidernode.hide()
		lightingbuttonnode.hide()
func _on_movement_control_button_2_pressed() -> void:
			#-1 = Drag back, 1 = Drag Forward
	Globals.MovementDirection = Globals.MovementDirection*-1
	var movementcontrolbuttonnode = get_node("PauseMenuList/MovementControlPadding/MovementControlButton2")
	
	#update text
	if Globals.MovementDirection == 1:
		movementcontrolbuttonnode.text = "Movement Control:
			Drag Forward"
	else:
		movementcontrolbuttonnode.text = "Movement Control:
			Drag Back"


func _on_zoom_slider_drag_ended(value_changed: bool) -> void:
	#change zoom and update cam
	var zoomslidernode = get_node("PauseMenuList/ZoomControlContainer/Zoom Slider")
	var camnode = get_node("/root/Node2D/PlayerCharacter/Eyes/Camera2D")
	Globals.game_zoom = (zoomslidernode.value / 25) + 1
	camnode.update_zoom()
	


func _on_lighting_button_pressed() -> void:
	Globals.lights_on = not Globals.lights_on
	#update text
	if Globals.lights_on == false:
		$PauseMenuList/LightingButton.text = "Lighting: Off"
	else:
		$PauseMenuList/LightingButton.text = "Lighting: On"
	var scenenode = get_node("/root//Node2D/Lights")
	print("try get func")
	scenenode.update_lighting()
