extends Control

# -------------------------------------------------------------------------------------------------
func fade_in() -> void:
	$Blur.show()
	$Text.show()
	$AnimationPlayer.play("fade_in")
	$AudioStreamPlayer.play()
