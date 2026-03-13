extends Node2D

@export var offset: Vector2 = Vector2(0, -24)
var is_showing := false

func _ready() -> void:
	visible = false

func show_text(text: String) -> void:
	var NPCtextnode = get_node("NPCspeechcontainer/NPCtxt")
	NPCtextnode.text = text
	is_showing = true
	visible = true

func hide_text() -> void:
	is_showing = false
	visible = false

func _process(_delta: float) -> void:
	if !visible:
		return
	# Stick above NPC
	global_position = get_parent().global_position + offset
