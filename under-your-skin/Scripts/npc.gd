extends Node2D

@export var talk_distance: float = 80.0
@export var lines: Array[String] = [
	"Hey there!",
	"Be careful out there.",
	"This place is dangerous."
]

@onready var speech_bubble = $SpeechBubble
@onready var exclaim = $Exclaim
@onready var talk_area: Area2D = $TalkArea
@onready var player: Node2D = get_tree().get_first_node_in_group("player")  # put Player in 'player' group

var player_in_range := false
var current_line_index := 0


@onready var anim_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	
	# start idle animation
	if anim_player.has_animation("idle"):
		anim_player.play("idle")
		
	exclaim.visible = false
	talk_area.body_entered.connect(_on_body_entered)
	talk_area.body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node) -> void:
	if body == player:
		player_in_range = true
		exclaim.show_with_fade()

func _on_body_exited(body: Node) -> void:
	if body == player:
		player_in_range = false
		exclaim.hide_with_fade()
		speech_bubble.hide_text()
		current_line_index = 0

@onready var eyes: Node2D = $Eyes

@export var eye_max_offset: float = 3   # how far eyes can move from center (pixels)
@export var eye_follow_speed: float = 10.0  # how fast eyes catch up to target
@export var eye_player_lag: float = 5.0

var eye_target_offset: Vector2 = Vector2.ZERO
var eye_current_offset: Vector2 = Vector2.ZERO

var player_pos
func _process(delta: float) -> void:
	
	#Eye Code Copy Pasted From Player
	if player_in_range:
		player_pos = player.global_position
	else:
		player_pos = get_global_mouse_position()
	var to_player = player_pos - global_position
	
	#if 0 here to prezent bugs, cause normalize freaks out
	if to_player == Vector2.ZERO:
		eye_target_offset = Vector2.ZERO
	else:
		
		var dir = to_player.normalized()
		#off set around npc
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
	
	if player == null:
		return
	
	
	
	# Safety: also check distance (in case physics glitches)
	var dist := global_position.distance_to(player.global_position)
	if dist > talk_distance and player_in_range:
		player_in_range = false
		exclaim.visible = false
		speech_bubble.hide_text()
		current_line_index = 0 

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_LEFT \
	and event.is_pressed():
		if player_in_range:
			# Advance text / show text on click
			_show_next_line()

func _show_next_line() -> void:
	if lines.is_empty():
		return

	# Hide exclamation as soon as they start talking
	exclaim.visible = false

	var text := lines[current_line_index]
	speech_bubble.show_text(text)
	current_line_index = (current_line_index + 1) % lines.size()
