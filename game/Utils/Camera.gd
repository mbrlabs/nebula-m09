extends Camera2D

var _intensity := 0.0
var _duration := 0.0
var _noise: OpenSimplexNoise

# -------------------------------------------------------------------------------------------------
func _ready():
	_noise = OpenSimplexNoise.new()
	_noise.seed = randi()
	_noise.octaves = 3
	_noise.period = 12
	_noise.persistence = 0.8
	
# -------------------------------------------------------------------------------------------------
func _process(delta: float) -> void:
	if _duration <= 0:
		set_process(false)
		offset = Vector2.ZERO
		_intensity = 0.0
		_duration = 0.0
	else:
		_duration -= delta
		var noise_x := _noise.get_noise_1d(OS.get_ticks_msec() * 0.1)
		var noise_y := _noise.get_noise_1d(OS.get_ticks_msec() * 0.1 + 100.0)
		offset = Vector2(noise_x, noise_y) * _intensity * 2.0

# -------------------------------------------------------------------------------------------------
func shake(intensity: float, duration: float) -> void:
	if intensity > _intensity && duration > _duration:
		set_process(true)
		_intensity = intensity
		_duration = duration
