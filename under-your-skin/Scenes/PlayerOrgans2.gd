extends Sprite2D
#initialises so that double jump animation can play
var used_double_jump: bool = false
var animation_time: float = 0.3
var animation_expansion: float = 10

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#gets playercharacter node
	var playernode = get_node("../..")#
	#checks if jump count = 0 and whetehr the animation has already played for this jump
	if playernode.jump_count == 0 and used_double_jump == false :
		#sets so that animation wont repeat
		used_double_jump = true
		print("Explode synapses!")
		hide()
	#explode animation
		#creates a tween
		var explodetween = create_tween()
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
		#waits until animatiomn over
		await explodetween.finished
		#delete sprite
		explode_effect.queue_free()

	#if jump_counts > 0
	if playernode.jump_count > 0:
		#allow the animation to be played next time [jump_ount] = 0
		used_double_jump = false
		#shows organ back
		show()
			#show
	pass
