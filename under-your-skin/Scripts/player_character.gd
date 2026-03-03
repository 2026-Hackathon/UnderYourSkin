extends CharacterBody2D

@export var gravity: float = 980.0
@export var fling_power: float = 80.0
@export var ground_friction: float = 0.3
@export var air_resistance: float = 0.02
@export var max_drag_distance: float = 100.0

@onready var preview_line: Line2D = $PreviewLine

var is_dragging: bool = false
var drag_start: Vector2
var body_scale_original: Vector2

func _ready():
	body_scale_original = scale
	preview_line.default_color = Color(1, 0, 0, 0.5)  # Red semi-transparent line
	preview_line.width = 10.0

func _input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				drag_start = get_global_mouse_position()
				is_dragging = true
				preview_line.clear_points()
				scale = body_scale_original * 1.1  # Visual feedback
			else:
				if is_dragging:
					var drag_end = get_global_mouse_position()
					var drag_vec = (drag_end - drag_start).limit_length(max_drag_distance)
					velocity = -drag_vec.normalized() * drag_vec.length() / 10.0 * fling_power
					is_dragging = false
					preview_line.clear_points()
					scale = body_scale_original

	elif event is InputEventMouseMotion and is_dragging:
		var current_pos = get_global_mouse_position()
		var drag_vec = current_pos - drag_start
		drag_vec = drag_vec.limit_length(max_drag_distance)
		
		preview_line.clear_points()
		preview_line.add_point(Vector2.ZERO)  # Relative to player
		preview_line.add_point(drag_vec)  # End point for preview

func _physics_process(delta: float):
	# Gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	# Friction/resistance on x velocity only (AFTER gravity)
	if is_on_floor():
		velocity.x = move_toward(velocity.x, 0.0, ground_friction * 200.0 * delta)  # Fixed: constant deceleration force
	else:
		velocity.x *= (1.0 - air_resistance)  # Air resistance stays the same
	move_and_slide()
