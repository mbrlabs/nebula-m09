extends Control

func fade_in() -> void:
	$Background.show()
	$Text.show()
	$AnimationPlayer.play("fade_in")
