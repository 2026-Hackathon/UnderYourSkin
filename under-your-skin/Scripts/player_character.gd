extends CharacterBody2D

@export var gravity: float = 980.0
@export var fling_power: float = 80.0
@export var air_resistance: float = 0.02
@export var max_drag_distance: float = 100.0
@export var air_jumps_max: int = 1
var air_jumps_count: int = 2 #Dummy Val, Replaced when intialized

@onready var tilemap_layer: TileMapLayer = get_tree().get_first_node_in_group("ground")

var is_dragging: bool = false
var drag_start: Vector2
var body_scale_original: Vector2
var current_friction: float = 1.0

#Initilaize some Vals
#Initilaize Player Size Needed so when scale is changed player remains Visible
func _ready():
	body_scale_original = scale  
	air_jumps_count = air_jumps_max
#Key Input
func _input(event: InputEvent):
	#If Input Is Mouse
	if event is InputEventMouseButton:
		
		#LeftMouse Events
		if event.button_index == MOUSE_BUTTON_LEFT:
			
			#On Press Get Starting Position
			if event.pressed  and air_jumps_count > 0:
				drag_start = get_global_mouse_position()
				is_dragging = true
				#Increase Player Size for Visual Cue
				scale = body_scale_original * 1.1
			#On Release
			else:
				#If Dragging should always true here
				#but here for Validation otherwise
				if is_dragging:
					var drag_end = get_global_mouse_position()
					var drag_vec = (drag_end - drag_start).limit_length(max_drag_distance)
					velocity = -drag_vec.normalized() * drag_vec.length() / 10.0 * fling_power
					#End Drag
					is_dragging = false
					#On release Size back to Normal
					scale = body_scale_original
					#Decrease Jump Count
					air_jumps_count -= 1

func _physics_process(delta: float):
	#Apply Gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		air_jumps_count = air_jumps_max

	# Friction/ Air resistance
	# Friciton only applys on Ground, Air Resistance always
	if is_on_floor():
		current_friction = get_tile_friction()
		velocity.x = move_toward(velocity.x, 0.0, (1.0 / current_friction) * 300.0 * delta)
	velocity *= (1.0 - air_resistance)

	#Godot Built in Move Larp
	move_and_slide()

#Helper Function: Gets Friction of current Tile
#Assumes 1.0 if not present.
func get_tile_friction() -> float:
	if tilemap_layer == null:
		return 1.0
	
	# Get collision position (foot position)
	var foot_pos = global_position + Vector2(0, 20)
	
	# Finds which tile player is standing on
	var tile_coords = tilemap_layer.local_to_map(tilemap_layer.to_local(foot_pos))
	var tile_data = tilemap_layer.get_cell_tile_data(tile_coords)  # Fixed: only Vector2i coords
	
	if tile_data:
		var physics_layer = tilemap_layer.tile_set.get_physics_layer(0)
		if physics_layer:
			var material = physics_layer.physics_material_override
			if material == null:
				material = physics_layer.physics_material
			if material:
				return material.friction
	return 1.0
