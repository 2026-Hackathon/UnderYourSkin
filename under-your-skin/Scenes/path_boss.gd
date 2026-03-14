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
	#gets random attack 1 to 3
	#rannum = rand(1,3)
	rannum = (randi() % 3 + 1)
		
	if rannum == 1:
		freezelaserattack()
	elif rannum == 2:
		disorientlaserattack()
	else:
		tendrilslapattack()

func freezelaserattack():
	pass
	
func disorientlaserattack():
	pass

func tendrilslapattack():
	pass
	
