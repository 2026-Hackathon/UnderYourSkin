extends Sprite2D

#base eye movement vars
@onready var eye: Node2D = $iris
@export var eye_max_offset: float = 8   # how far eyes can move from center (pixels)
@export var eye_follow_speed: float = 20.0  # how fast eyes catch up to target
@export var eye_player_lag: float = 5.0
@onready var playernode = get_node("/root/Node2D/PlayerCharacter")
var eye_target_offset: Vector2 = Vector2.ZERO
var eye_current_offset: Vector2 = Vector2.ZERO



var eyeangle: float

#check vars
var in_attack: bool = false
#should eyes move?
var inrem: bool = true	




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
# Called every frame. 'delta' is the elapsed time since the previous frame.
# Called every frame. 'delta' is the elapsed time since the previous frame.
#moves eyes to player if not attacking. if attacking then moves to the last player position so long as in rem	
var playerpos
var to_player
func _process(delta: float) -> void:

	if inrem and not Globals.is_frozen:
		#if not in an attack, keep updating where to look
		if not in_attack:
			playerpos = playernode.global_position
			to_player = playerpos - global_position
			
		#if 0 here to prezent bugs, cause normalize freaks out
		if to_player == Vector2.ZERO:
			eye_target_offset = Vector2.ZERO
		else:
					
			var dir = to_player.normalized() 
			dir = dir.rotated(-PI/2)
			eyeangle = dir.angle()
			
				#off set around player
			eye_target_offset = dir * eye_max_offset  # stays in a circle around center
			
		# smooth lag done using lerp
			eye_current_offset = eye_current_offset.lerp(eye_target_offset, eye_follow_speed * delta)
			#apply offset, also changes camera pov cause childed
			eye.position = eye_target_offset
