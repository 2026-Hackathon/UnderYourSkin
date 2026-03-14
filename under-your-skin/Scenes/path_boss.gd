extends Path2D
@export var eye_ball_speed: float = 100.0
#1 in this many times per frame
@export var chance_for_attack: int = 240
var in_attack: bool = false
var timer: float = 0.0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

var rannum: int = 0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not in_attack:
		#increments timer by delta
		timer += (delta * Globals.current_time_scale)
		
		if timer >= 1:
			rannum = (randi() % 10) + 1
			print(rannum)
			timer -=1
			if rannum == 10:
				attack()
		
		moveacrosspath(delta)

func moveacrosspath(delta: float):
		$"Follow Path".progress += eye_ball_speed * Globals.current_time_scale

func attack():
	in_attack = true
	$"Follow Path/CharacterBody2D/Eyeball Back".in_attack = true
	await get_tree().create_timer(2.0).timeout
	$"Follow Path/CharacterBody2D/Eyeball Back".inrem = true
	#gets random attack 1 to 3
	#rannum = rand(1,3)
	#rannum = (randi() % 3 + 1)
	rannum = 1
		
	if rannum == 1:
		freezelaserattack()
	elif rannum == 2:
		disorientlaserattack()
	else:
		tendrilslapattack()

func freezelaserattack():
	#Glow Iris
	#create large yellow rectangle
	#create rectangluar collision
	createlaser(100)
	#if collides with player then player.velocity = 0
	#tween rectangle to get wider and thinner until disappears
	#stop iris glow (parallel?)
	#turn off in_attack
	pass
	
func disorientlaserattack():
	in_attack = false

func tendrilslapattack():
	in_attack = false

@export var laser_length: int = 2000
func createlaser(width):
	var area = Area2D.new()
	var shape = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	var angle: float = $"Follow Path/CharacterBody2D/Eyeball Back".eyeangle
	
	#make rect shape
	rect.size = Vector2(laser_length, width)
	
	shape.shape = rect
	area.add_child(shape)
	
	#YELLOW BEAM
	var vis = ColorRect.new()                     # Create ColorRect
	vis.color = Color(1, 1, 0, 1)               # Yellow
	vis.size = Vector2(laser_length, width)     # Same size as collision
	vis.pivot_offset = Vector2(laser_length/2, width/2)  # Pivot to match collision mid-right
	area.add_child(vis)
	
	#ROTATE
	area.rotation = angle + (PI / 2)
	
	area.monitoring = true
	#give position
	area.position = $"Follow Path/CharacterBody2D".global_position - Vector2(laser_length / 2,0).rotated((angle + (PI / 2)))
	print("MADE LASER")
	#connect signal
	area.body_entered.connect(freezeplayer)
	
	get_tree().current_scene.add_child(area)
func freezeplayer():
	print("BZHHHHH")
