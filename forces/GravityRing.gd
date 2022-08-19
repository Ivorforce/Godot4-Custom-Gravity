class_name GravityRing extends Spatial

export var start_radius = 1.0
export var half_falloff_offset = 10
export var max_acceleration = 9.81
export var ortho_vector := Vector3(1, 0, 0)

onready var collision_shape: CollisionShape = $CollisionShape

# g = b / (d - a)^2
var _a;
var _b;

func _ready():
	reconfigure_from_params();

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

func get_acceleration_at(position: Vector3) -> Vector3:
	var difference = global_transform.origin - position
	difference -= difference.project(ortho_vector)
	
	var distance = difference.length()
	return difference / distance * get_acceleration_at_distance(distance)
