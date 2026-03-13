extends Node2D

@onready var eyes: Node2D = $Eyes

@export var eye_max_offset: float = 3   # how far eyes can move from center (pixels)
@export var eye_follow_speed: float = 10.0  # how fast eyes catch up to target
@export var eye_player_lag: float = 5.0

var eye_target_offset: Vector2 = Vector2.ZERO
var eye_current_offset: Vector2 = Vector2.ZERO
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var mouse_pos = get_global_mouse_position()
	var to_mouse = mouse_pos - global_position
	
	#if 0 here to prezent bugs, cause normalize freaks out
	if to_mouse == Vector2.ZERO:
		eye_target_offset = Vector2.ZERO
	else:
			
		var dir = to_mouse.normalized() 
			#off set around player
		eye_target_offset = dir * eye_max_offset  # stays in a circle around center
		
		#flips eyes depending on where mouse is
		if dir.x < 0:
			eyes.get_node("EyeSprite").flip_h = true 
		else:
			eyes.get_node("EyeSprite").flip_h = false
	
	# smooth lag done using lerp
		eye_current_offset = eye_current_offset.lerp(eye_target_offset, eye_follow_speed * delta)
		#apply offset, also changes camera pov cause childed
		eyes.position = eye_current_offset
