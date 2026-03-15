extends Control

@onready var scroll: ScrollContainer = $ScrollContainer
@onready var label: Label = $ScrollContainer/MarginContainer/Label

@export var scroll_speed: float = 40.0
@export var main_menu_scene: PackedScene

var scroll_top: float = 0.0
var scroll_target: float = 0.0
var at_bottom: bool = false

func _ready() -> void:
	# Must wait for layout so ScrollContainer has a computed size.
	await get_tree().process_frame
	
	# Ensure both nodes are valid (if paths are wrong this will show the error).
	assert(scroll != null, "ScrollContainer not found")
	assert(label != null, "Label not found")
	
	# Optional: make sure vertical scrolling is actually enabled.
	scroll.scroll_vertical = 0.0

func _process(delta: float) -> void:
	if scroll == null or label == null:
		return
	if at_bottom:
		if main_menu_scene:
			var timer := get_tree().create_timer(1.0)
			await timer.timeout
			get_tree().change_scene_to_packed(main_menu_scene)
		return
	
	# Get how far we can scroll (read this every frame to be safe).
	var min_size: Vector2 = label.get_minimum_size()
	var scroll_range: float = max(0.0, min_size.y - scroll.rect_size.y)
	
	# Advance scroll position.
	scroll_top = scroll.scroll_vertical
	scroll_top += scroll_speed * delta
	if scroll_top >= scroll_range:
		scroll_top = scroll_range
		at_bottom = true
	scroll.scroll_vertical = scroll_top
