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

func _ready() -> void:
	exclaim.visible = false
	talk_area.body_entered.connect(_on_body_entered)
	talk_area.body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node) -> void:
	if body == player:
		player_in_range = true
		exclaim.visible = true

func _on_body_exited(body: Node) -> void:
	if body == player:
		player_in_range = false
		exclaim.visible = false
		speech_bubble.hide_text()

func _process(delta: float) -> void:
	if player == null:
		return
	
	# Safety: also check distance (in case physics glitches)
	var dist := global_position.distance_to(player.global_position)
	if dist > talk_distance and player_in_range:
		player_in_range = false
		exclaim.visible = false
		speech_bubble.hide_text()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_LEFT \
	and event.is_pressed():
		if player_in_range:
			# Advance text / show text on click
			_show_next_line()

func _show_next_line() -> void:
	if lines.is_empty():
		return
	
	# simple cycling dialogue
	var text := lines[current_line_index]
	speech_bubble.show_text(text)
	current_line_index = (current_line_index + 1) % lines.size()
