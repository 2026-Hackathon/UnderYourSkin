
extends Node2D
@export var health: int = 10
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not Globals.is_frozen:
		if lasering and $"PathBoss/Follow Path/CharacterBody2D/Eyeball Back Boss/laser/Laser AREA".overlaps_body(playernode):
			freezelasereffect()
		if health < 1:
			death()
func attack():
	#stop moving
	$"PathBoss/Follow Path/CharacterBody2D/Eyeball Back Boss".in_attack = true
	$PathBoss.in_attack = true
	#wait 2s
	await get_tree().create_timer(2.0).timeout
	#stop eyes moving
	$"PathBoss/Follow Path/CharacterBody2D/Eyeball Back Boss".inrem = false
	#run laser
	freezelaserattack()

var lasering: bool = false
@onready var playernode = get_node("/root/Node2D/PlayerCharacter")
func freezelaserattack():
	#show collision and sprite
	$"PathBoss/Follow Path/CharacterBody2D/Eyeball Back Boss/laser".show()
	#rotate collision and sprite
	$"PathBoss/Follow Path/CharacterBody2D/Eyeball Back Boss/laser".rotation = ($"PathBoss/Follow Path/CharacterBody2D/Eyeball Back Boss".eyeangle)

	lasering = true
		#wait 5s
	await get_tree().create_timer(5.0).timeout
	#hide collision and sprtie
	$"PathBoss/Follow Path/CharacterBody2D/Eyeball Back Boss/laser".hide()
	#stop attacking -> let body move, let eyes move
	$"PathBoss/Follow Path/CharacterBody2D/Eyeball Back Boss".inrem = true
	$"PathBoss/Follow Path/CharacterBody2D/Eyeball Back Boss".in_attack = false
	$"PathBoss".in_attack = false
	lasering = false
	
	
	



func _on_laser_area_body_entered(body: Node2D) -> void:
	if lasering == true:
		print("Body entered")
		if body.name == "PlayerCharacter":
			print("Found Player")
			freezelaserattack()

func freezelasereffect():
	playernode.velocity.x = 0
	playernode.velocity.y = 0

#player hits weakpoint
func _on_weak_point_area_body_entered(body: Node2D) -> void:
	#take damage
	print("Damage")
	health -= 1
	#damage animation
	damageanimaton()
	#knock back player?
	
func damageanimaton():

	$"PathBoss/Follow Path/CharacterBody2D/Eyeball Back Boss".self_modulate = Color(1,0,0,0.5)
	await get_tree().create_timer(0.5).timeout
	$"PathBoss/Follow Path/CharacterBody2D/Eyeball Back Boss".self_modulate = Color(1,1,1,1)

func death():
	#play animation
	$PathBoss.hide()
	$DeathPath.show()
