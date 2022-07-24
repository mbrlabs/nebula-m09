class_name Level
extends Control

# -------------------------------------------------------------------------------------------------
var _env: Environment = preload("res://Assets/game_env.tres")
onready var _tilemap: TileMap = $TileMap
onready var _player: Player = $TileMap/Player
onready var _player_mirrored: Player = $TileMap/PlayerMirrored
onready var _orbs: Node = $TileMap/Orbs

var _occupied_positions: Dictionary # Vector2 -> bool

# -------------------------------------------------------------------------------------------------
func _ready() -> void:
	_player.connect("moving_back", self, "_on_player_moving_back")
	_player.connect("moving_forward", self, "_on_player_moving_forward")
	_player_mirrored.connect("moving_back", self, "_on_player_moving_back")
	_player_mirrored.connect("moving_forward", self, "_on_player_moving_forward")

# -------------------------------------------------------------------------------------------------
func move(direction: int) -> void:
	var mirrored_direction := Utils.mirror_direction(direction)
	var last_moved_direction := _player.get_last_moved_direction()
	var moving_back: bool = (last_moved_direction != Types.Direction.NONE) && (last_moved_direction == mirrored_direction)
	if _can_move(direction, mirrored_direction) || moving_back:
		_player.move(direction)
		_player_mirrored.move(mirrored_direction)
		if moving_back:
			SoundEffects.move_back()
		else:
			SoundEffects.move()
	else:
		_player.indicate_failed_move(direction)
		_player_mirrored.indicate_failed_move(mirrored_direction)
		SoundEffects.impact()
		get_parent().get_parent().impact_effect() # TODO: change to signal

# -------------------------------------------------------------------------------------------------
func is_moving() -> bool:
	return _player.is_moving() || _player_mirrored.is_moving()

# -------------------------------------------------------------------------------------------------
func is_solved() -> bool:
	return _are_all_orbs_collected() && _is_closed_loop()

# -------------------------------------------------------------------------------------------------
func reset() -> void:
	_player.reset()
	_player_mirrored.reset()
	_occupied_positions.clear()

# -------------------------------------------------------------------------------------------------
func _are_all_orbs_collected() -> bool:
	for orb in _orbs.get_children():
		if !(_player.has_collected_orb(orb) || _player_mirrored.has_collected_orb(orb)):
			return false
	return true

# -------------------------------------------------------------------------------------------------
func _is_closed_loop() -> bool:
	return _player.is_closed_loop()

# -------------------------------------------------------------------------------------------------
func _can_move(direction: int, mirrored_direction: int) -> bool:
	var move_pos_3 := _player.dry_move(direction, 3)
	var move_pos_2 := _player.dry_move(direction, 2)
	var move_pos_1 := _player.dry_move(direction, 1)
	var mirrored_move_pos_3 := _player_mirrored.dry_move(mirrored_direction, 3)
	var mirrored_move_pos_2 := _player_mirrored.dry_move(mirrored_direction, 2)
	var mirrored_move_pos_1 := _player_mirrored.dry_move(mirrored_direction, 1)
	
	# players can't move to their opposites starting position
	if move_pos_3 == _player_mirrored.get_tail_position() || mirrored_move_pos_3 == _player.get_tail_position():
		return false
	
	# head on collision
	if move_pos_3 == mirrored_move_pos_3:
		return false
	
	# basic collisions with walls and lines, which are already there
	var p1 := _can_move_to(move_pos_3) && _can_move_to(move_pos_2) && _can_move_to(move_pos_1)
	var p2 := _can_move_to(mirrored_move_pos_3) && _can_move_to(mirrored_move_pos_2) && _can_move_to(mirrored_move_pos_1)
	return p1 && p2

# -------------------------------------------------------------------------------------------------
func _can_move_to(target: Vector2) -> bool:
	# Player collision
	if _occupied_positions.has(target):
		return false
	
	# Map collision
	var grid_pos := _tilemap.world_to_map(_tilemap.to_local(target))
	if _tilemap.get_cellv(grid_pos) == TileMap.INVALID_CELL:
		return false

	return true

# -------------------------------------------------------------------------------------------------
func _on_player_moving_forward(from: Vector2, to: Vector2) -> void:
	_occupied_positions[to] = true

# -------------------------------------------------------------------------------------------------
func _on_player_moving_back(from: Vector2, to: Vector2) -> void:
	_occupied_positions.erase(from)
