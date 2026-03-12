extends Node2D

@export var talk_distance: float = 80.0
@export var lines: Array[String] = [
	"Hey there!",
	"Be careful out there.",
	"This place is dangerous."
]
@export var lines2: Array[String] = [
	"Listen to me now",
	"Whatever happens...",
	"Dont let it get UNDER YOUR SKIN",
	"It'll be alright"
]

@onready var speech_bubble = $SpeechBubble
@onready var exclaim = $Exclaim
@onready var talk_area: Area2D = $TalkArea
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var eyes: Node2D = $Eyes


@export var eye_max_offset: float = 3
@export var eye_follow_speed: float = 10.0
@export var eye_player_lag: float = 5.0

var player: Node2D
var player_in_range := false
var current_line_index := 0
var currentlines: int = 1

var player_pos: Vector2 = Vector2.ZERO
var eye_target_offset: Vector2 = Vector2.ZERO
var eye_current_offset: Vector2 = Vector2.ZERO

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	
	if anim_player.has_animation("idle"):
		anim_player.play("idle")
	
	exclaim.visible = false
	talk_area.body_entered.connect(_on_body_entered)
	talk_area.body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node) -> void:
	# Area2D can be kept for visual feedback only
	pass

func _on_body_exited(body: Node) -> void:
	# Covered by distance check below
	pass

func _process(delta: float) -> void:
	if Globals.is_frozen:
		return
	
	# Re‑acquire player if needed
	if player == null:
		player = get_tree().get_first_node_in_group("player")
		if player == null:
			return
	
	# ----- RANGE CHECK (works in any direction) -----
	var dist := global_position.distance_to(player.global_position)
	var in_range_now := dist <= talk_distance
	
	# Enter range
	if in_range_now and not player_in_range:
		player_in_range = true
		exclaim.show_with_fade()
	
	# Leave range
	if not in_range_now and player_in_range:
		player_in_range = false
		exclaim.hide_with_fade()
		speech_bubble.hide_text()
		current_line_index = 0
	
	# Eyes follow player when close, mouse otherwise
	if player_in_range:
		player_pos = player.global_position
	else:
		player_pos = get_global_mouse_position()
	
	var to_player := player_pos - global_position
	if to_player == Vector2.ZERO:
		eye_target_offset = Vector2.ZERO
	else:
		var dir := to_player.normalized()
		eye_target_offset = dir * eye_max_offset
		eyes.get_node("EyeSprite").flip_h = dir.x < 0
	
	eye_current_offset = eye_current_offset.lerp(eye_target_offset, eye_follow_speed * delta)
	eyes.position = eye_current_offset

func _input(event: InputEvent) -> void:
	if not Globals.is_frozen:
		if event is InputEventMouseButton \
		and event.button_index == MOUSE_BUTTON_LEFT \
		and event.is_pressed():
			if player_in_range:
				_show_next_line()

func _show_next_line() -> void:
	if currentlines == 1:
		if lines.is_empty():
			return
			# Hide exclamation as soon as they start talking
		exclaim.visible = false  # or exclaim.hide_with_fade() if you want fade
	
		var text := lines[current_line_index]
		speech_bubble.show_text(text)
		current_line_index = (current_line_index + 1) % lines.size()
	else:
		if lines2.is_empty():
			return
						# Hide exclamation as soon as they start talking
		exclaim.visible = false  # or exclaim.hide_with_fade() if you want fade
			
		var text := lines2[current_line_index]
		speech_bubble.show_text(text)
		current_line_index = (current_line_index + 1) % lines2.size()
			

func switchlines():

	currentlines = 2
	
