class_name GravityShaped extends Spatial

export var start_radius = 1.0
export var half_falloff_offset = 10
export var max_acceleration = 9.81

export var gravity_cutoff = 0.01

onready var collision_shape: CollisionShape = $"../CollisionShape"
onready var influence_shape: CollisionShape = $InfluenceShape

# g = b / (d - a)^2
var _a: float
var _b: float

func _ready():
	reconfigure_from_params();

func reconfigure_from_params():
	var half_falloff_radius = start_radius + half_falloff_offset
	
	# 1 = b / (start - a)^2
	# 0.5 = b / (halfway - a)^2
	_a = (start_radius - sqrt(0.5) * half_falloff_radius) / (1 - sqrt(0.5))
	_b = pow(start_radius - _a, 2);
	
	# gravity_cutoff = a / (cutoff_distance - b)^2
	var cutoff_distance = sqrt(abs(_a) / gravity_cutoff) + _b
	influence_shape.scale = Vector3(cutoff_distance, cutoff_distance, cutoff_distance)
	
func get_acceleration_at_distance(distance: float) -> float:
	var adjusted_distance = max(0.001, distance - _a)
	var influence = min(1, _b / (adjusted_distance * adjusted_distance))
	return influence * max_acceleration

func find_closest_surface_point(position: Vector3, shape: CollisionShape) -> Vector3:
	var p := collision_shape.global_transform.affine_inverse() * position
	
	if shape.shape is CapsuleShape:
		return collision_shape.global_transform * find_closest_surface_point_capsule(p, collision_shape.shape as CapsuleShape)
	# ...
	
	assert(false, "Not a supported shape.");
	return Vector3.ZERO

func find_closest_surface_point_capsule(p: Vector3, shape: CapsuleShape) -> Vector3:
	# Adapted from https://iquilezles.org/articles/distfunctions/
	var half_height = shape.height / 2
	var line_loc := Vector3(0, 0, clamp(p.z, -half_height, half_height));
	return line_loc + (p - line_loc).normalized() * shape.radius

func get_acceleration_at(position: Vector3) -> Vector3:
	# FIXME What this really needs is a signed distance function. See: https://github.com/godotengine/godot-proposals/issues/5218
	var collision_point := find_closest_surface_point(position, collision_shape)
	
	var difference := collision_point - position
	var distance := difference.length()
	return difference / distance * get_acceleration_at_distance(distance)
