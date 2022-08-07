extends Control

export var display_time_seconds := 30
onready var _tips := [$Tip1, $Tip2, $Tip3, $Tip4]
var _current_tip := 0
var _tween: SceneTreeTween

# -------------------------------------------------------------------------------------------------
func show_tip() -> void:
	if _current_tip < _tips.size():
		hide_tips()
		var tip: Label = _tips[_current_tip]
		_tween = get_tree().create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
		_tween.tween_property(tip, "modulate:a", 1.0, 0.5)
		_tween.tween_property(tip, "modulate:a", 0.0, 0.5).set_delay(display_time_seconds)
		_tween.play()
	
		_current_tip += 1
		
# -------------------------------------------------------------------------------------------------
func hide_tips() -> void:
	if _tween != null:
		_tween.stop()
	for l in get_children():
		if l is Label:
			l.modulate.a = 0
