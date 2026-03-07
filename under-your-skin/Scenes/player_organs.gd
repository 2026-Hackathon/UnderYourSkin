extends NinePatchRect


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#get playercharacter script
	var playernode = get_node("../..")	
	if playernode.jump_count == 0:
		#run disappear animation
		hide()
		
		#when jump_count returns to >0, show again
	else: 
	pass
