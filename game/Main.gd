extends Control

# -------------------------------------------------------------------------------------------------
const LEVELS := [
	"res://Levels/Level_1.tscn",
	"res://Levels/Level_2.tscn",
]

# -------------------------------------------------------------------------------------------------
onready var _level: Level = $Level_1
var _level_done := false
var _current_level_index := 0
var _next_buffered_input_direction: int = Types.Direction.NONE

# -------------------------------------------------------------------------------------------------
func _ready() -> void:
	$Music.play(10)
	_level.connect("win_animation_finished", self, "_on_win_animation_finished")

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
	_level.start_win_animation()
	SoundEffects.success()

# -------------------------------------------------------------------------------------------------
func _on_win_animation_finished() -> void:
	if _current_level_index + 1 < LEVELS.size():
		_current_level_index += 1
		_level.queue_free()
		_level = load(LEVELS[_current_level_index]).instance()
		_level_done = false
		add_child(_level)
		_level.connect("win_animation_finished", self, "_on_win_animation_finished")
		print("Loading new level...")
	else:
		# TODO: show game over text
		print("Game Over")

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
