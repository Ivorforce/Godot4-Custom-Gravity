extends Spatial

export var gravity_cutoff = 0.01

export var inner_shape: Shape
onready var bounding_shape: CollisionShape = $BoundingShape
onready var falloff_model = $FalloffModel

func _ready():
	reconfigure_from_params();

func reconfigure_from_params():
	falloff_model.reconfigure_from_params()
	
	# gravity_cutoff = a / (cutoff_distance - b)^2
	var cutoff_distance = falloff_model.get_distance_for_acceleration(gravity_cutoff)
	
	if inner_shape is CapsuleShape:
		(bounding_shape.shape as CapsuleShape).radius = (inner_shape as CapsuleShape).radius + cutoff_distance
	# TODO Support for other shapes
	else:
		assert(false, "Not a supported shape.");
	
func find_closest_surface_point(position: Vector3) -> Vector3:
	# Help me get merged! https://github.com/godotengine/godot-proposals/issues/5218
	var p := global_transform.affine_inverse() * position
	
	if inner_shape is CapsuleShape:
		return global_transform * find_closest_surface_point_capsule(p, inner_shape as CapsuleShape)
	# TODO Support for other shapes
	else:
		assert(false, "Not a supported shape.");
		return Vector3.ZERO

func find_closest_surface_point_capsule(p: Vector3, shape: CapsuleShape) -> Vector3:
	# Adapted from https://iquilezles.org/articles/distfunctions/
	var half_height = shape.height / 2
	var line_loc := Vector3(0, 0, clamp(p.z, -half_height, half_height));
	return line_loc + (p - line_loc).normalized() * shape.radius

func get_acceleration_at(position: Vector3) -> Vector3:
	var collision_point := find_closest_surface_point(position)
	
	var difference := collision_point - position
	var distance := difference.length()
	return difference / distance * falloff_model.get_acceleration_at_distance(distance)
