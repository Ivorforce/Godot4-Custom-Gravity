extends Node

@export var start_radius := 1.0
@export var half_falloff_offset := 10.0
@export var max_acceleration := 9.81

# g = b / (d - a)^2
var _a: float
var _b: float

func reconfigure_from_params():
	var half_falloff_radius = start_radius + half_falloff_offset
	
	# 1 = b / (start - a)^2
	# 0.5 = b / (halfway - a)^2
	_a = (start_radius - sqrt(0.5) * half_falloff_radius) / (1 - sqrt(0.5))
	_b = pow(start_radius - _a, 2);

func get_acceleration_at_distance(distance: float) -> float:
	var adjusted_distance = max(0.001, distance - _a)
	var influence = min(1, _b / (adjusted_distance * adjusted_distance))
	return influence * max_acceleration

func get_distance_for_acceleration(acceleration: float) -> float:
	return sqrt(abs(_a / acceleration)) + _b
