extends Area2D

var cutsceneover: bool = false	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_body_entered(body):
	print("Who goes?")
	if body.name == "PlayerCharacter":
		print("ITS the plauer")
		if cutsceneover == true:
			print("Change the text now")
			changenpctext()
		else: 
			print("Must be a cutscene")
			cutsceneover = true	
func changenpctext():
	var startnpcnode = get_node("../StartNPC")
	startnpcnode.switchlines()
	queue_free()
func _on_area_entered(area: Area2D) -> void:
	pass
