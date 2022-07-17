extends Control

signal level_selected(num)

# -------------------------------------------------------------------------------------------------
func _process(delta: float) -> void:
	if visible && Input.is_action_just_pressed("close_overlay"):
		hide()

# -------------------------------------------------------------------------------------------------
func set_solved(num: int) -> void:
	get_node("SolvedIndicators/Level%d" % num).modulate.a = 0.5

# -------------------------------------------------------------------------------------------------
func _on_BackButton_pressed() -> void:
	SoundEffects.move()
	hide()

# -------------------------------------------------------------------------------------------------
func _on_Button_Level1_pressed() -> void:
	_load_level(1)

# -------------------------------------------------------------------------------------------------
func _on_Button_Level2_pressed() -> void:
	_load_level(2)

# -------------------------------------------------------------------------------------------------
func _on_Button_Level3_pressed() -> void:
	_load_level(3)

# -------------------------------------------------------------------------------------------------
func _on_Button_Level4_pressed() -> void:
	_load_level(4)

# -------------------------------------------------------------------------------------------------
func _on_Button_Level5_pressed() -> void:
	_load_level(5)

# -------------------------------------------------------------------------------------------------
func _on_Button_Level6_pressed() -> void:
	_load_level(6)

# -------------------------------------------------------------------------------------------------
func _on_Button_Level7_pressed() -> void:
	_load_level(7)

# -------------------------------------------------------------------------------------------------
func _load_level(num: int) -> void:
	hide()
	SoundEffects.move()
	emit_signal("level_selected", num)
