extends Node

@onready var music_a: AudioStreamPlayer2D = $MusicA
@onready var music_b: AudioStreamPlayer2D = $MusicB

# Assign up to 10 tracks in the inspector
@export var tracks: Array[AudioStream] = []

@export var fade_time: float = 3.0

var current_player: AudioStreamPlayer2D
var next_player: AudioStreamPlayer2D

func _ready() -> void:
	if tracks.is_empty():
		return
	
	current_player = music_a
	next_player = music_b
	
	# Start with a random track
	var first_track := _pick_random_track()
	current_player.stream = first_track
	current_player.volume_db = 0.0
	current_player.play()
	
	# Connect finished signal (Godot 4: "finished")
	current_player.finished.connect(_on_current_track_finished)
func _process(_delta: float) -> void:
	music_a.volume_db = Globals.sound_volume
	music_b.volume_db = Globals.sound_volume
func _pick_random_track() -> AudioStream:
	if tracks.is_empty():
		return null
	var idx := randi() % tracks.size()
	return tracks[idx]
func _on_current_track_finished() -> void:
	# select next random track
	var new_stream := _pick_random_track()
	if new_stream == null:
		return
	
	# swap roles: current ↔ next
	var old_player := current_player
	var new_player := next_player
	current_player = new_player
	next_player = old_player
	
	# set up new track
	current_player.stream = new_stream
	current_player.volume_db = -40.0  # start quiet
	current_player.play()
	
	# fade old out, new in
	_fade_cross(old_player, current_player, fade_time)
	
	# reconnect finished on the new current
	# (disconnect old first for safety)
	for c in old_player.finished.get_connections():
		old_player.finished.disconnect(c.callable)
	current_player.finished.connect(_on_current_track_finished)
func _fade_cross(from_player: AudioStreamPlayer2D, to_player: AudioStreamPlayer2D, duration: float) -> void:
	var tween := create_tween()
	tween.set_parallel(true)
	
	# from: 0 dB → -40 dB (fade out)
	tween.tween_property(from_player, "volume_db", -40.0, duration)
	# to: -40 dB → 0 dB (fade in)
	tween.tween_property(to_player, "volume_db", 0.0, duration)
	
	# stop old player when done
	tween.set_parallel(false)
	tween.tween_callback(func():
		from_player.stop()
	)
