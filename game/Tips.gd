extends Control

export var display_time_seconds := 30

onready var _tips := [$Tip1, $Tip2, $Tip3]
onready var _tween: Tween = $Tween

var _current_tip := 0

# -------------------------------------------------------------------------------------------------
func show_tip() -> void:
	if _current_tip < _tips.size():
		var tip: Label = _tips[_current_tip]
		_tween.remove_all()
		_tween.interpolate_property(tip, "modulate:a", 0.0, 1.0, 0.5, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
		_tween.interpolate_property(tip, "modulate:a", 1.0, 0.0, 0.5, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT, display_time_seconds)
		_tween.start()
		_current_tip += 1
		
# -------------------------------------------------------------------------------------------------
func hide_tips() -> void:
	_tween.stop_all()
	_tween.remove_all()
	for l in get_children():
		if l is Label:
			l.modulate.a = 0
