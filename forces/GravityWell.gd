class_name GravityWell extends Spatial

export var start_radius = 1.0
export var half_falloff_offset = 10
export var max_acceleration = 9.81

export var gravity_cutoff = 0.01

onready var collision_shape: CollisionShape = $CollisionShape

# g = b / (d - a)^2
var _a;
var _b;

func _ready():
	reload_from_params();

func reload_from_params():
	var half_falloff_radius = start_radius + half_falloff_offset
	
	# 1 = b / (start - a)^2
	# 0.5 = b / (halfway - a)^2
	_a = (start_radius - sqrt(0.5) * half_falloff_radius) / (1 - sqrt(0.5))
	_b = pow(start_radius - _a, 2);
	
	# gravity_cutoff = a / (cutoff_distance - b)^2
	var cutoff_distance = sqrt(_a / gravity_cutoff) + _b
	(collision_shape.shape as SphereShape).radius = cutoff_distance

func get_acceleration_at_distance(distance: float):
	var normalized_distance = max(0, distance - _a)
	var influence = min(1, _b / (normalized_distance * normalized_distance))
	return influence * max_acceleration

func get_acceleration_at(position: Vector3):
	var difference = global_transform.origin - position
	return difference.normalized() * get_acceleration_at_distance(difference.length())
