extends Sprite2D

var tween = null

var bounce_offset_y: float = 2.0
var bounce_speed: float = 2.0
var start_y
func _ready() -> void:
	start_y = position.y
func _process(delta: float) -> void:
	if !visible:
		return

	# Bounce using a simple time-like value (Engine.time → use an internal float)
	var t := Time.get_ticks_msec() / 1000.0  # seconds
	var bounce_amount := sin(t * bounce_speed) * bounce_offset_y
	position.y = bounce_amount + start_y
	
func show_with_fade() -> void:
	if tween:
		tween.kill()
	show()
	modulate.a = 0.0
	tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.3)
	# no set_trans; just use default linear transition

func hide_with_fade() -> void:
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.2)
	tween.finished.connect(func():
		hide()
	)
