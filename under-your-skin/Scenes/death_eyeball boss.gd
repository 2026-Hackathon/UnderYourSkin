extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func died():
	var bossbodynode = get_node("/root/Node2D/Boss/PathBoss/Follow Path/CharacterBody2D")
	var start_pos = bossbodynode.global_position
	var end_pos = Vector2(0,0)
	$"Death Eyeball".position = start_pos
	var tween = create_tween()
	tween.tween_property($"Death Eyeball", "position", end_pos, 10)
