extends Path2D
@export var eye_ball_speed: float = 25.0
var deathanimon: bool = false
var timer: float = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#only moves when not attacking and not paused
	if deathanimon and not Globals.is_frozen:
		#increments timer by delta
		timer += (delta * Globals.current_time_scale)
		moveacrosspath(delta)
	
func moveacrosspath(delta: float):

	$"Follow Path".progress += eye_ball_speed * Globals.current_time_scale

func died():
	var BossNode = get_node("/root/Node2D/Boss/PathBoss/Follow Path/CharacterBody2D")
	curve.add_point(BossNode.global_position)
	curve.add_point(Vector2(0,0))
	deathanimon = true
