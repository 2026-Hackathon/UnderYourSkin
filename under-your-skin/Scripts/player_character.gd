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
@onready var animation_player = get_node("AnimationPlayer")

@export var max_deform_scale: Vector2 = Vector2.ONE
var original_scale: Vector2


#Eyes

@onready var eyes: Node2D = $Eyes

@export var eye_max_offset: float = 3   # how far eyes can move from center (pixels)
@export var eye_follow_speed: float = 10.0  # how fast eyes catch up to target
@export var eye_player_lag: float = 5.0

var eye_target_offset: Vector2 = Vector2.ZERO
var eye_current_offset: Vector2 = Vector2.ZERO

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
	var was_on_floor: bool = false
	var was_on_floor_prev = was_on_floor
	was_on_floor = is_on_floor()
	
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
	was_on_floor = is_on_floor()
	
	
	#Squashes Based on Velocity
	#abs needed otherwise squash bad
	#Change max_deform to change this
	if not animation_player.is_playing():
		sprite.scale.y = lerp(original_scale.y , max_deform_scale.y , abs(delta * velocity.x))
		sprite.scale.x = lerp(original_scale.x , max_deform_scale.x , abs(delta * velocity.y))
	
	
	# Animation Player
	#Detects where collision is then plays corresponding anim
	#Anim played relative to velocity before collision
	#Adjust Values if they feel off
	#Landing condition kinda bullshit but works.
	if not was_on_floor_prev and was_on_floor and pre_move_velocity.y > 50.0:
		animation_player.speed_scale = clamp(500 /pre_move_velocity.length(), 0,10)
		animation_player.play("hit_floor")
	if is_on_ceiling() and pre_move_velocity.y < -50.0:
		animation_player.speed_scale = clamp(pre_move_velocity.length()/500, 1,10)
		animation_player.play("hit_cieling")
	if is_on_wall():
		if pre_move_velocity.x < -50:
			animation_player.speed_scale = clamp(pre_move_velocity.length()/250, 1.5,8)
			animation_player.play("hit_wall_left")
		elif pre_move_velocity.x > 50:
			animation_player.speed_scale = clamp(pre_move_velocity.length()/250, 1.5,8)
			animation_player.play("hit_wall_right")
	#Resets max Jumps, should prevent buggy jump behaviour causing an extra jump
	if is_on_floor():
		#If you touch the Floor Bullet Time turns off
		bullet_time_active = false
		jump_count = max_jumps
	#Applies Bounce
	apply_bounce(pre_move_velocity)


#This is entirely to make eyes worl
func _process(delta: float) -> void:
	# Get mouse pos
	var mouse_pos = get_global_mouse_position()
	var to_mouse = mouse_pos - global_position
	
	#if 0 here to prezent bugs, cause normalize freaks out
	if to_mouse == Vector2.ZERO:
		eye_target_offset = Vector2.ZERO
	else:
		#-1 to be replaced with future options var
		var dir = to_mouse.normalized() * -1
		#off set around player
		eye_target_offset = dir * eye_max_offset  # stays in a circle around center
		
		#flips eyes depending on where mouse is
		if dir.x < 0:
			eyes.get_node("Camera2D/EyeSprite").flip_h = true 
		else:
			eyes.get_node("Camera2D/EyeSprite").flip_h = false
	
	# smooth lag done using lerp
	eye_current_offset = eye_current_offset.lerp(eye_target_offset, eye_follow_speed * delta)
	#apply offset, also changes camera pov cause childed
	eyes.position = eye_current_offset
	
	
func apply_bounce(pre_move_velocity: Vector2) -> void:
	var collided := false
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		var normal := collision.get_normal()
		
		# Get bounce value for where we hit
		var bounce_value := get_data_val_at(collision.get_position(), "BounceValue") as float		
		if bounce_value != null:
			var speed_into_surface = -pre_move_velocity.dot(normal)
			if abs(speed_into_surface) > 50.0:  # Moving INTO surface
				velocity = pre_move_velocity.bounce(normal) * bounce_value
				
				collided = true
				#Debug
				print("BOUNCE! Normal: ", normal, " Speed into surface: ", speed_into_surface, "Bounce:", bounce_value)
	# If should Bounce, applies second move
	if collided:
		move_and_slide()
#Gets custom friction value using the below abstract function
func get_tile_friction() -> float:
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		var friction_val := get_data_val_at(collision.get_position(), "Friction") as float
		if friction_val != null:
			return friction_val
	return 1.0

#Custom data grabber, give collision pos + Data identifier
# If no tile, or no custom data, returns "default".
func get_data_val_at(coll_pos: Vector2, data_to_get):
	if tilemap_layer == null:
		return null
	# Try 3 nearby positions to catch the tile
	var offsets = [Vector2.ZERO, Vector2(-8, 0), Vector2(0, -8)]
	
	for offset in offsets:
		var sample_pos = coll_pos + offset
		var tile_coords = tilemap_layer.local_to_map(tilemap_layer.to_local(sample_pos))
		var tile_data := tilemap_layer.get_cell_tile_data(tile_coords)
		
		if tile_data:
			var custom_data_value : Variant = tile_data.get_custom_data(data_to_get)
			if custom_data_value != null:
				return custom_data_value
	
	return null
