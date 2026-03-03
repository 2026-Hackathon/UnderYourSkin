extends CharacterBody2D

@export var gravity: float = 980.0
@export var fling_power: float = 80.0
@export var air_resistance: float = 0.0002
@export var max_drag_distance: float = 100.0

#Jumps kinda buggy if velocity = 0 before jumping get an extra jump effectivley
@export var max_jumps: int = 2
var jump_count: int = 2 #Dummy Val, Replaced when intialized

@onready var tilemap_layer: TileMapLayer = get_tree().get_first_node_in_group("ground")

var is_dragging: bool = false
var drag_start: Vector2
var body_scale_original: Vector2
var current_friction: float = 1.0

#Initilaize some Vals
#Initilaize Player Size Needed so when scale is changed player remains Visible
func _ready():
	body_scale_original = scale  
	jump_count = max_jumps

# Key Input
func _input(event: InputEvent):
	#If Input Is Mouse, crashes if not here
	if event is InputEventMouseButton:
		#LeftMouse Events
		if event.button_index == MOUSE_BUTTON_LEFT:
			
			#On Press Get Starting Position
			if event.pressed  and jump_count > 0:
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
					jump_count -= 1

func _physics_process(delta: float):
	#Apply Gravity/Reset Jumps
	if not is_on_floor():
		velocity.y += gravity * delta
	# Friction/ Air resistance
	if is_on_floor():
		current_friction = get_tile_friction()
		var friction_strength = 3000.0 * current_friction
		velocity.x = move_toward(velocity.x, 0.0, friction_strength * delta)
	velocity *= (1.0 - air_resistance)
	
	#For Bounce, stores previous velocity so it functions properly
	var pre_move_velocity := velocity
	
	#Godot Built in Larper, Applies Velocity
	move_and_slide()
	#Resets max Jumps, should prevent buggy jump behaviour causing an extra jump
	if is_on_floor():
		jump_count = max_jumps
	#Applies Bounce
	apply_bounce(pre_move_velocity)
#Bounce Function, vibecoded
func apply_bounce(pre_move_velocity: Vector2) -> void:
	var collided := false
	
	#Kinda inefficient, may slow game on low end devices but fuck em
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		var normal := collision.get_normal()

		# Get bounce value for where we hit
		var bounce_value := get_collision_tile_bounce(collision.get_position())

		if bounce_value > 0.0:
			# FIXED: Check pre_move velocity AND collision normal direction
			var speed_into_surface = -pre_move_velocity.dot(normal)
			if speed_into_surface > 20.0:  # Moving INTO surface
				velocity = pre_move_velocity.bounce(normal) * bounce_value
				print("BOUNCE! Normal: ", normal, " Speed into surface: ", speed_into_surface)

	# If should Bounce, applies second move
	if collided:
		move_and_slide()

#Helper Functions: Gets Tile Values
#Ngl these were vibe coded af hope they work well
func get_tile_friction() -> float:
	if tilemap_layer == null:
		return 1.0
	
	var foot_pos = global_position + Vector2(0, 20)
	var tile_coords = tilemap_layer.local_to_map(tilemap_layer.to_local(foot_pos))
	var tile_data = tilemap_layer.get_cell_tile_data(tile_coords)
	
	if tile_data:
		# FIXED: Use correct TileSet method
		if tilemap_layer.tile_set.get_physics_layers_count() > 0:
			var phys_material = tilemap_layer.tile_set.get_physics_layer_physics_material(0)
			if phys_material:
				print("Friction: ", phys_material.friction)
				return phys_material.friction
	return 1.0
func get_tile_bounce() -> float:
	if tilemap_layer == null:
		return 0.0
	
	var foot_pos = global_position + Vector2(0, 20)
	var tile_coords = tilemap_layer.local_to_map(tilemap_layer.to_local(foot_pos))
	var tile_data = tilemap_layer.get_cell_tile_data(tile_coords)
	
	if tile_data:
		if tilemap_layer.tile_set.get_physics_layers_count() > 0:
			var phys_material = tilemap_layer.tile_set.get_physics_layer_physics_material(0)
			if phys_material:
				print("Bounce: ", phys_material.bounce)
				return phys_material.bounce
	return 0.0
#Gets Tile Colliding With
func get_collision_tile_bounce(coll_pos: Vector2) -> float:
	if tilemap_layer == null:
		return 0.0
	
	var tile_coords = tilemap_layer.local_to_map(tilemap_layer.to_local(coll_pos))
	var tile_data = tilemap_layer.get_cell_tile_data(tile_coords)
	
	if tile_data:
		if tilemap_layer.tile_set.get_physics_layers_count() > 0:
			var phys_material = tilemap_layer.tile_set.get_physics_layer_physics_material(0)
			if phys_material:
				return phys_material.bounce
	return 0.0
