extends Area2D

@export var target_scene: PackedScene      # assign in inspector
@export var pull_duration: float = 1.5     # time spent spiralling
@export var final_scale: float = 0.1       # how small the player gets
@export var spiral_radius: float = 64.0    # starting radius of spiral
@export var rotations: float = 2.0         # how many turns before center

var pulling: bool = false
var player: CharacterBody2D
var pull_time: float = 0.0
var start_scale: Vector2
var start_radius: float

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if pulling:
		return
	if body.is_in_group("player"):
		player = body as CharacterBody2D
		_start_pull()

func _start_pull() -> void:
	if player == null:
		return
	pulling = true
	pull_time = 0.0
	start_scale = player.scale
	start_radius = spiral_radius
	
	Globals.is_frozen = true
	player.velocity = Vector2.ZERO

func _process(delta: float) -> void:
	if not pulling or player == null:
		return
	
	pull_time += delta
	var t: float = clamp(pull_time / pull_duration, 0.0, 1.0)
	
	var radius: float = lerp(start_radius, 0.0, t)
	var angle: float = lerp(0.0, rotations * TAU, t)
	
	var offset: Vector2 = Vector2(radius, 0.0).rotated(angle)
	player.global_position = global_position + offset
	
	var s: float = lerp(1.0, final_scale, t)
	player.scale = start_scale * s
	
	if t >= 1.0:
		_teleport_player()

func _teleport_player() -> void:
	pulling = false
	
	if target_scene:
		get_tree().change_scene_to_packed(target_scene)
	else:
		Globals.is_frozen = false
