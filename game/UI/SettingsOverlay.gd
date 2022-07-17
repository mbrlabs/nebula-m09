extends Control

# -------------------------------------------------------------------------------------------------
func _ready() -> void:
	$Sound/SoundSlider.value = _get_bus_volume("Sound")
	$Music/MusicSlider.value = _get_bus_volume("Music")

# -------------------------------------------------------------------------------------------------
func _process(delta: float) -> void:
	if visible && Input.is_action_just_pressed("close_overlay"):
		hide()

# -------------------------------------------------------------------------------------------------
func _on_BackButton_pressed() -> void:
	SoundEffects.move()
	hide()

# -------------------------------------------------------------------------------------------------
func _on_SoundSlider_value_changed(value: float) -> void:
	_change_bus_volume("Sound", value)

# -------------------------------------------------------------------------------------------------
func _on_MusicSlider_value_changed(value: float) -> void:
	_change_bus_volume("Music", value)

# -------------------------------------------------------------------------------------------------
func _change_bus_volume(bus: String, value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus), linear2db(value))

# -------------------------------------------------------------------------------------------------
func _get_bus_volume(bus: String) -> float:
	return db2linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index(bus)))
