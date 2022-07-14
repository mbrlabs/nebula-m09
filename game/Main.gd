extends Control

# -------------------------------------------------------------------------------------------------
const LEVELS := [
	"res://Levels/Level_1.tscn",
	"res://Levels/Level_10.tscn",
	"res://Levels/Level_2.tscn",
	"res://Levels/Level_3.tscn",
	"res://Levels/Level_4.tscn",
	"res://Levels/Level_5.tscn",
]

# -------------------------------------------------------------------------------------------------
onready var _puzzle_solved_tween: Tween = $PuzzleSolvedTween
onready var _env: Environment = $WorldEnvironment.environment
onready var _camera: Camera2D = $Camera
var _level: Level
var _level_done := false
var _current_level_index := 0
var _next_buffered_input_direction: int = Types.Direction.NONE

# -------------------------------------------------------------------------------------------------
func _ready() -> void:
	$Music.play(10)
	_load_level(LEVELS[0])

# -------------------------------------------------------------------------------------------------
func _process(delta: float) -> void:
	if !_level_done:
		if _level.is_solved():
			_level_done = true
			_handle_solved_level()
		else:
			_do_move()
	
	if OS.get_name() != "HTML5" && Input.is_action_just_pressed("quit"):
		get_tree().quit()
	
	if Input.is_action_just_pressed("restart"):
		SoundEffects.impact()
		_level.reset()
	
# -------------------------------------------------------------------------------------------------
func _do_move() -> void:
	var direction := _get_input_direction()
	if direction != Types.Direction.NONE:
		if _level.is_moving():
			_next_buffered_input_direction = direction
		else:
			_level.move(direction)
			_next_buffered_input_direction = Types.Direction.NONE
	elif _next_buffered_input_direction != Types.Direction.NONE:
		if !_level.is_moving():
			_level.move(_next_buffered_input_direction)
			_next_buffered_input_direction = Types.Direction.NONE

# -------------------------------------------------------------------------------------------------
func _handle_solved_level() -> void:
	var glow_target := _env.glow_intensity + 3
	var dur := 0.25
	_puzzle_solved_tween.remove_all()
	_puzzle_solved_tween.connect("tween_all_completed", self, "_on_puzzle_solved_tween_finished")
	_puzzle_solved_tween.interpolate_property(_env, "glow_intensity", _env.glow_intensity, glow_target, dur, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	_puzzle_solved_tween.interpolate_property(_env, "glow_intensity", glow_target, _env.glow_intensity, dur*1.2, Tween.TRANS_CUBIC, Tween.EASE_IN, dur*1.5)
	_puzzle_solved_tween.start()
	_camera.shake(1.25, 0.3)
	SoundEffects.success()

# -------------------------------------------------------------------------------------------------
func _on_puzzle_solved_tween_finished() -> void:
	yield(get_tree().create_timer(0.1), "timeout")
	_puzzle_solved_tween.disconnect("tween_all_completed", self, "_on_puzzle_solved_tween_finished")
	if _current_level_index + 1 < LEVELS.size():
		_current_level_index += 1
		_load_level(LEVELS[_current_level_index])
	else:
		# TODO: show game over text
		print("Game Over")

# -------------------------------------------------------------------------------------------------
func _load_level(level: String) -> void:
	if _level != null:
		_level.queue_free()
	_level = load(level).instance()
	_level_done = false
	add_child(_level)
	
# -------------------------------------------------------------------------------------------------
func _get_input_direction() -> int:
	if Input.is_action_just_pressed("move_down"):
		return Types.Direction.DOWN
	if Input.is_action_just_pressed("move_up"):
		return Types.Direction.UP
	if Input.is_action_just_pressed("move_left"):
		return Types.Direction.LEFT
	if Input.is_action_just_pressed("move_right"):
		return Types.Direction.RIGHT
	return Types.Direction.NONE
