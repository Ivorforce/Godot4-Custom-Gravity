class_name ScrewGravity extends Spatial

export var full_rotation_vector = Vector3(1, 0, 0)
export var start_down = Vector3.DOWN
export var is_clockwise = true
export var acceleration = 9.81

var _rotation_vector: Vector3
var _distance_per_rotation: float

var _a: Vector3
var _b: Vector3

onready var collision_shape: CollisionShape = $CollisionShape

func _ready():
	reconfigure_from_params();

func reconfigure_from_params():
	_a = start_down
	_b = full_rotation_vector.normalized().cross(_a)
	
	_distance_per_rotation = full_rotation_vector.length()
	_rotation_vector = full_rotation_vector / _distance_per_rotation
	
	if not is_clockwise:
		_b = -_b

func get_acceleration_at(position: Vector3) -> Vector3:
	var difference := position - global_transform.origin
	var progression := difference.project(_rotation_vector).length() / _distance_per_rotation * 2 * PI
	return (_a * cos(progression) + _b * sin(progression)) * acceleration
