tool
class_name Player
extends Node2D

# -------------------------------------------------------------------------------------------------
const MOVEMENT_STEP := 32
const MOVEMENT_STEP_INVALID_MOVE := 16

const COLOR_BLUE := Color("#3186ff")
const COLOR_RED := Color("#ff4e4e")

# -------------------------------------------------------------------------------------------------
signal moving_forward(from, to)
signal moving_back(from, to)

# -------------------------------------------------------------------------------------------------
export var mirrored: bool = false
onready var _line: Line2D = $Line2D
onready var _failure_particles: CPUParticles2D = $Head/FailureParticles
onready var _start: Sprite = $Start
onready var _head: Area2D = $Head
onready var _main_player_indicator: Node2D = $Head/MainPlayerIndicator
var _move_in_progress := false
var _directions: Array

# -------------------------------------------------------------------------------------------------
func _ready() -> void:
	var color := COLOR_BLUE
	if mirrored:
		color = COLOR_RED
		_main_player_indicator.hide()
	_start.self_modulate = color
	_failure_particles.color = color
	if !Engine.editor_hint:
		_line.texture = LineTexture.texture
		_line.add_point(Vector2.ZERO)
		_line.default_color = color

# -------------------------------------------------------------------------------------------------
func _process(delta: float) -> void:
	if Engine.editor_hint:
		var color := COLOR_BLUE
		if mirrored:
			color = COLOR_RED
		if _start != null:
			_start.self_modulate = color

# -------------------------------------------------------------------------------------------------
func has_collected_orb(orb: Node2D) -> bool:
	if _line.points.empty():
		return false
	
	var point_pairs := _line.points.size() - 1
	for i in point_pairs:
		var tail: Vector2 = _line.points[i]
		var head: Vector2 = _line.points[i+1]
		var expected_pos := tail + (head-tail) / 2.0
		expected_pos = _line.to_global(expected_pos)
		if abs(expected_pos.distance_to(orb.global_position)) < 10:
			return true
	return false

# -------------------------------------------------------------------------------------------------
func reset() -> void:
	_directions.clear()
	_line.clear_points()
	_line.add_point(Vector2.ZERO)
	_move_in_progress = false
	_head.position = Vector2.ZERO

# -------------------------------------------------------------------------------------------------
func is_moving() -> bool:
	return _move_in_progress

# -------------------------------------------------------------------------------------------------
func move(direction: int, steps: int = 3) -> void:
	if !_move_in_progress:
		# Check if we moved back
		var mirrored_direction := Utils.mirror_direction(direction)
		var moved_back := false
		if !_directions.empty():
			var last_direction: int = _directions[_directions.size()-1]
			if last_direction == mirrored_direction:
				moved_back = true
		
		# Move
		if moved_back:
			_move_back()
		else:
			_move_forward(direction, steps)

# -------------------------------------------------------------------------------------------------
func dry_move(direction: int, steps: int = 3) -> Vector2:
	var direction_vector := Utils.direction_to_vector(direction)
	var target := _line.points[_line.get_point_count() - 1]
	target += direction_vector * steps * MOVEMENT_STEP
	return _line.to_global(target)

# -------------------------------------------------------------------------------------------------
func get_head_position() -> Vector2:
	var head := _line.points[_line.get_point_count() - 1]
	return _line.to_global(head)

# -------------------------------------------------------------------------------------------------
func get_tail_position() -> Vector2:
	return _line.to_global(_line.points[0])

# -------------------------------------------------------------------------------------------------
func indicate_failed_move(direction: int) -> void:
	if !_move_in_progress:
		var direction_vector := Utils.direction_to_vector(direction)
		var initial_offset := direction_vector * 0.25
		var from := _line.points[_line.get_point_count() - 1] + initial_offset
		var to := from + direction_vector * MOVEMENT_STEP_INVALID_MOVE - initial_offset
		
		_line.add_point(from)
		
		var tween := get_tree().create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tween.tween_method(self, "_set_latest_point_position", from, to, 0.1)
		tween.tween_method(self, "_set_latest_point_position", to, from, 0.06)
		tween.tween_callback(self, "_on_failed_move_indication_tween_done")
		tween.play()
		
		_failure_particles.emitting = true
		_move_in_progress = true
		
# -------------------------------------------------------------------------------------------------
func get_last_moved_direction() -> int:
	if _directions.empty():
		return Types.Direction.NONE
	else:
		return _directions[_directions.size() - 1] 

# -------------------------------------------------------------------------------------------------
func is_closed_loop() -> bool:
	if _line.get_point_count() < 2:
		return false
	return _line.points[0] == _line.points[_line.get_point_count() - 1]

# -------------------------------------------------------------------------------------------------
func _move_forward(direction: int, steps: int) -> void:
	var direction_vector := Utils.direction_to_vector(direction)
	var initial_offset := direction_vector
	var from := _line.points[_line.get_point_count() - 1] + initial_offset
	var to := from + direction_vector * steps * MOVEMENT_STEP - initial_offset
	emit_signal("moving_forward", _line.to_global(from), _line.to_global(to))
	
	# Add new point
	_line.add_point(from)
	_directions.append(direction)
	
	# Tween the new point to to the target
	var tween := get_tree().create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_method(self, "_set_latest_point_position", from, to, 0.12)
	tween.tween_callback(self, "_on_move_forward_tween_done")
	tween.play()

	_move_in_progress = true

# -------------------------------------------------------------------------------------------------
func _move_back() -> void:
	var from: Vector2 = _line.points[_line.get_point_count() - 1]
	var to: Vector2 = _line.points[_line.get_point_count() - 2]
	to += to.direction_to(from)
	emit_signal("moving_back", _line.to_global(from), _line.to_global(to))

	# Tween the new point to to the target
	var tween := get_tree().create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_method(self, "_set_latest_point_position", from, to, 0.08)
	tween.tween_callback(self, "_on_move_back_tween_done")
	tween.play()
	
	_move_in_progress = true

# -------------------------------------------------------------------------------------------------
func _on_move_forward_tween_done() -> void:
	_move_in_progress = false

# -------------------------------------------------------------------------------------------------
func _on_move_back_tween_done() -> void:
	_move_in_progress = false
	_directions.remove(_directions.size() - 1)
	_line.remove_point(_line.get_point_count() - 1)

# -------------------------------------------------------------------------------------------------
func _on_failed_move_indication_tween_done() -> void:
	_move_in_progress = false
	_line.remove_point(_line.get_point_count() - 1)

# -------------------------------------------------------------------------------------------------
func _set_latest_point_position(point: Vector2) -> void:
	_line.set_point_position(_line.get_point_count()- 1, point)
	_head.position = point
