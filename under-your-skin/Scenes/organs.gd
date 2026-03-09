extends Sprite2D
#initialises vars
var animation_time: float = 0.3
var animation_expansion: float = 10
var explodetween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called when explosion should occur i.e when double jumping
func explosion():
	#uncomment for debug
		print("Explode synapses!")
		hide()
	#explode animation
		#creates a tween
		explodetween = create_tween()
		#creates explosion effect sprite
		var explode_effect = Sprite2D.new()
		explode_effect.texture = preload("res://Sprites/Player/PlayerSpriteSheet.png")
		explode_effect.region_enabled = true
		#gets region of sprite sheet to reference
		explode_effect.region_rect = Rect2(19, 18, 12, 12)
		explode_effect.global_position = global_position
		#initialise scale
		explode_effect.scale = Vector2(1, 1)
		#add the sprite to the scene
		get_tree().current_scene.add_child(explode_effect)	
		#expands to [animation_expansion]x scale and fades to nun in [animation_time] seconds
		explodetween.parallel().tween_property(explode_effect, "scale", Vector2(animation_expansion, animation_expansion), animation_time)
		explodetween.parallel().tween_property(explode_effect, "modulate:a", 0.0, animation_time)
		#waits for tween to end
		await explodetween.finished
		#delete sprite
		explode_effect.queue_free()
		
#restores players organs
func _restoreorgans():
	show()
	#pauses the explosion amnimation
func pause_explosion():
	if explodetween:
		explodetween.pause()
		#resumes explosion animation
func resume_explosion():
	if explodetween:
		explodetween.play()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
		
