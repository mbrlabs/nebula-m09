extends Node

# -------------------------------------------------------------------------------------------------
func mirror_direction(direction: int) -> int:
	match direction:
		Types.Direction.LEFT: return Types.Direction.RIGHT
		Types.Direction.RIGHT: return Types.Direction.LEFT
		Types.Direction.UP: return Types.Direction.DOWN
		Types.Direction.DOWN: return Types.Direction.UP
		_: return Types.Direction.NONE

# -------------------------------------------------------------------------------------------------
func direction_to_vector(direction: int) -> Vector2:
	match direction:
		Types.Direction.DOWN: return Vector2.DOWN
		Types.Direction.UP: return Vector2.UP
		Types.Direction.RIGHT: return Vector2.RIGHT
		Types.Direction.LEFT: return Vector2.LEFT
	return Vector2.ZERO
