extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$OptionMenu.hide()
	$BackButtonContainer.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_playbutton_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/TempScene.tscn")


func _on_option_button_pressed() -> void:
	$MainMenu.hide()
	$OptionMenu.show()
	$BackButtonContainer.show()

func _on_back_button_pressed() -> void:
	$OptionMenu.hide()
	$BackButtonContainer.hide()
	$MainMenu.show()


func _on_movement_control_button_pressed() -> void:
		#-1 = Drag back, 1 = Drag Forward
	Globals.MovementDirection = Globals.MovementDirection*-1
	if Globals.MovementDirection == 1:
		$OptionMenu/VBoxContainer/MovementControlButton.text = "Movement Control: Drag Forward"
	else:
		$OptionMenu/VBoxContainer/MovementControlButton.text = "Movement Control: Drag Back"
		
