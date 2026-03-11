extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Hides the other menus upin start
	$OptionMenu.hide()
	$BackButtonContainer.hide()
	$"OptionMenu/OptionMenuPadding/OptionList/ZoomControlContainer/Zoom Slider".value = 25


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_playbutton_pressed() -> void:
	#play button opens level scene
	get_tree().change_scene_to_file("res://Scenes/GameLevel.tscn")


func _on_option_button_pressed() -> void:
	#hides main menu components and shows option menu components
	$MainMenu.hide()
	$OptionMenu.show()
	$BackButtonContainer.show()

func _on_back_button_pressed() -> void:
	#hides option menu components and shows main menu componenets
	$OptionMenu.hide()
	$BackButtonContainer.hide()
	$MainMenu.show()


func _on_movement_control_button_pressed() -> void:
		#-1 = Drag back, 1 = Drag Forward
	Globals.MovementDirection = Globals.MovementDirection*-1
	#update text
	if Globals.MovementDirection == 1:
		$OptionMenu/OptionMenuPadding/OptionList/MovementControlButton.text = "Movement Control:
			Drag Forward"
	else:
		$OptionMenu/OptionMenuPadding/OptionList/MovementControlButton.text = "Movement Control:
			Drag Back"
		


func _on_zoom_slider_drag_ended(value_changed: bool) -> void:
	var slidernode = get_node("OptionMenu/OptionMenuPadding/OptionList/ZoomControlContainer/Zoom Slider")
	Globals.game_zoom = (slidernode.value / 25) + 1
