extends Control

# -------------------------------------------------------------------------------------------------
enum State {
	PLAYING,
	DONE,
}

# -------------------------------------------------------------------------------------------------
const LEVELS := [
	"res://Levels/Level_1.tscn",
	"res://Levels/Level_2.tscn",
	"res://Levels/Level_3.tscn",
	"res://Levels/Level_4.tscn",
	"res://Levels/Level_5.tscn",
	"res://Levels/Level_6.tscn",
	"res://Levels/Level_7.tscn",
	"res://Levels/Level_8.tscn",
	"res://Levels/Level_9.tscn",
]

# -------------------------------------------------------------------------------------------------
onready var _puzzle_solved_tween: Tween = $PuzzleSolvedTween
onready var _env: Environment = $WorldEnvironment.environment
onready var _camera: Camera2D = $Camera
onready var _tip_timer: Timer = $TipTimer
onready var _tips: Control = $Tips
onready var _level_container: Control = $LevelContainer
var _state: int = State.PLAYING
var _solved_levels_indices := {} # int -> bool
var _level: Level
var _level_done := false
var _current_level_index := 0
var _next_buffered_input_direction: int = Types.Direction.NONE

# -------------------------------------------------------------------------------------------------
func _ready() -> void:
	if OS.get_name() == "HTML5":
		$Menu/ExitButton.disabled = true
		
	$Music.play(10)
	_load_level(LEVELS[0])

# -------------------------------------------------------------------------------------------------
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("screenshot"):
		var image = get_viewport().get_texture().get_data()
		image.flip_y()
		image.save_png("E:\\nebula.png")
	
	if _state == State.PLAYING:
		if !_level_done:
			if _level.is_solved():
				_level_done = true
				_handle_solved_level()
			else:
				_do_move()
		
		if Input.is_action_just_pressed("restart"):
			SoundEffects.impact()
			_level.reset()
	
# -------------------------------------------------------------------------------------------------
func _input(event: InputEvent) -> void:
	if _state == State.DONE && event is InputEventKey:
		get_tree().reload_current_scene()

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
func impact_effect() -> void:
	$Chroma/AnimationPlayer.play("chroma")
	_camera.shake(5, 0.06)

# -------------------------------------------------------------------------------------------------
func _handle_solved_level() -> void:
	var glow_target := _env.glow_intensity + 3
	var bloom_target := _env.glow_bloom + 0.0005
	
	var dur := 0.25
	var dur2 := dur*1.2
	var dur_offset := dur*1.5
	_puzzle_solved_tween.remove_all()
	_puzzle_solved_tween.connect("tween_all_completed", self, "_on_puzzle_solved_tween_finished")
	_puzzle_solved_tween.interpolate_property(_env, "glow_intensity", _env.glow_intensity, glow_target, dur, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	_puzzle_solved_tween.interpolate_property(_env, "glow_bloom", _env.glow_bloom, bloom_target, dur, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	_puzzle_solved_tween.interpolate_property(_env, "glow_intensity", glow_target, _env.glow_intensity, dur2, Tween.TRANS_CUBIC, Tween.EASE_IN, dur_offset)
	_puzzle_solved_tween.interpolate_property(_env, "glow_bloom", bloom_target, _env.glow_bloom, dur2, Tween.TRANS_CUBIC, Tween.EASE_IN, dur_offset)
	_puzzle_solved_tween.start()
	_camera.shake(1.25, 0.3)
	SoundEffects.success()

# -------------------------------------------------------------------------------------------------
func _on_puzzle_solved_tween_finished() -> void:
	yield(get_tree().create_timer(0.1), "timeout")
	_puzzle_solved_tween.disconnect("tween_all_completed", self, "_on_puzzle_solved_tween_finished")
	
	_solved_levels_indices[_current_level_index] = true
	$LevelSelectOverlay.set_solved(_current_level_index + 1)
	
	if _solved_levels_indices.size() == LEVELS.size():
		yield(get_tree().create_timer(0.25), "timeout")
		_state = State.DONE
		$ThanksOverlay.fade_in() 
	else:
		_increment_to_next_level()
		_load_level(LEVELS[_current_level_index])
		_tip_timer.start()
		_tips.hide_tips()

# -------------------------------------------------------------------------------------------------
func _increment_to_next_level() -> void:
	while true:
		_current_level_index += 1
		if _current_level_index >= LEVELS.size():
			_current_level_index = 0
		if !_solved_levels_indices.has(_current_level_index):
			break

# -------------------------------------------------------------------------------------------------
func _load_level(level: String) -> void:
	if _level != null:
		_level.queue_free()
	_level = load(level).instance()
	_level_done = false
	_level_container.add_child(_level)
	
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

# -------------------------------------------------------------------------------------------------
func _on_TipTimer_timeout() -> void:
	_tips.show_tip()

# -------------------------------------------------------------------------------------------------
func _on_ExitButton_pressed() -> void:
	get_tree().quit()

# -------------------------------------------------------------------------------------------------
func _on_SettingsButton_pressed() -> void:
	$SettingsOverlay.show()
	SoundEffects.move()

# -------------------------------------------------------------------------------------------------
func _on_SelectLevelButton_pressed() -> void:
	$LevelSelectOverlay.show()
	SoundEffects.move()

# -------------------------------------------------------------------------------------------------
func _on_LevelSelectOverlay_level_selected(num: int) -> void:
	var index := num - 1
	if index < LEVELS.size():
		_current_level_index = index
		_load_level(LEVELS[index])
