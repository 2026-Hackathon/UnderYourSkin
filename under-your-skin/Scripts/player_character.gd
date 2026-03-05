extends CharacterBody2D

#Physics Vars
@export var gravity: float = 800.0
@export var fling_power: float = 60.0
@export var air_resistance: float = 0.002
@export var max_drag_distance: float = 100.0
@export var momentum_conserve: float = 0.2 #Howmuch Velocity to be conserved between jumps
#Drag Vars
var is_dragging: bool = false
var drag_start: Vector2
var current_friction: float = 2.0


#Jumps kinda buggy if velocity = 0 before jumping get an extra jump effectivley
@export var max_jumps: int = 2
var jump_count: int = 2 #Dummy Val, Replaced when intialized

#Bullet Time Vars
@export var normal_time_scale: float = 1
@export var bullet_time_scale: float = 0.2
@export var time_ramp_speed: float = 3.0   
var bullet_time_active: bool = false
var current_time_scale: float = 1.0


#Grabs Tilemap on Start of Scene
@onready var tilemap_layer: TileMapLayer = get_tree().get_first_node_in_group("ground")

#Visual Vars
#Get the sprite
@onready var sprite: Sprite2D = get_node("PlayerSprite")
var original_scale: Vector2

#Initilaize some Vals
#Initilaize Player Size Needed so when scale is changed player remains Visible
func _ready():
	original_scale = scale  
	jump_count = max_jumps

#General Physics Functions Below
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
				
				#Bullet Time Active
				bullet_time_active = true
				current_time_scale = bullet_time_scale
				Engine.time_scale = current_time_scale
				
				#Increase Player Size for Visual Cue
				scale = original_scale * 1.1
				
			#On Release
			else:
				#If Dragging should always true here
				#but here for Validation otherwise
				if is_dragging:
					var drag_end = get_global_mouse_position()
					var drag_vec = (drag_end - drag_start).limit_length(max_drag_distance)
					
					velocity = (velocity*momentum_conserve)-drag_vec.normalized() * drag_vec.length() / 10.0 * fling_power
					#Decrease Jump Count
					jump_count -= 1
					#End Drag
					is_dragging = false
					
					#End Bullet Time
					bullet_time_active = false
					
					
					#On release Size back to Normal
					scale = original_scale
func _physics_process(delta: float):
	#Bullet Time
	if bullet_time_active:
		#Lerps Time, back to normal
		#rate Depends on bullet Time
		current_time_scale = move_toward(current_time_scale, normal_time_scale, time_ramp_speed * Engine.time_scale * delta)
	else:
		current_time_scale = move_toward(current_time_scale, normal_time_scale, 50.0 * time_ramp_speed * Engine.time_scale * delta)
	Engine.time_scale = current_time_scale
	
	
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
	
	#Godot Built in Lerper, Applies Velocity
	move_and_slide()
	#Resets max Jumps, should prevent buggy jump behaviour causing an extra jump
	if is_on_floor():
		#If you touch the Floor Bullet Time turns off
		bullet_time_active = false
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

		#if bounce_value > 0.0:
			# FIXED: Check pre_move velocity AND collision normal direction
		var speed_into_surface = -pre_move_velocity.dot(normal)
		if abs(speed_into_surface) > 40.0:  # Moving INTO surface
				velocity = pre_move_velocity.bounce(normal) * bounce_value
				
				collided = true
				print("BOUNCE! Normal: ", normal, " Speed into surface: ", speed_into_surface, "Bounce:", bounce_value)

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
#Gets Tile Colliding With
func get_collision_tile_bounce(coll_pos: Vector2) -> float:
	if tilemap_layer == null:
		return 0.0
	
	# Try 3 nearby positions
	var offsets = [Vector2.ZERO, Vector2(-8, 0), Vector2(0, -8)]
	
	for offset in offsets:
		var sample_pos = coll_pos + offset
		var tile_coords = tilemap_layer.local_to_map(tilemap_layer.to_local(sample_pos))
		var tile_data = tilemap_layer.get_cell_tile_data(tile_coords)
		
		if tile_data:
			if tilemap_layer.tile_set.get_physics_layers_count() > 0:
				var phys_material = tilemap_layer.tile_set.get_physics_layer_physics_material(0)
				if phys_material:
					return phys_material.bounce
	
	return 0.0
