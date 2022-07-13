class_name Gem
extends Node2D

var collected := false

func _on_Area2D_area_entered(area: Area2D) -> void:
	var node = area.get_parent()
	if node is Player:
		collected = !collected
		#print("Collected: %s" % collected)
