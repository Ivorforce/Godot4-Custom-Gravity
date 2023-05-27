extends Node3D

@export var gravity_cutoff = 0.01

@onready var inner_shape: CollisionShape3D = $InnerShape
@onready var bounding_shape: CollisionShape3D = CollisionShape3D.new()
@onready var falloff_model = $FalloffModel

func _ready():
	inner_shape.disabled = true  # We only need this for reference
	reconfigure_from_params();
	self.add_child(bounding_shape)

func reconfigure_from_params():
	falloff_model.reconfigure_from_params()
	
	# gravity_cutoff = a / (cutoff_distance - b)^2
	var cutoff_distance = falloff_model.get_distance_for_acceleration(gravity_cutoff)
	
	if inner_shape.shape is CapsuleShape3D:
		var shape := inner_shape.shape as CapsuleShape3D
		bounding_shape.shape = CapsuleShape3D.new()
		bounding_shape.shape.radius = shape.radius + cutoff_distance + 50
		bounding_shape.shape.height = shape.height + cutoff_distance * 2 + 50
	# TODO Support for other shapes
	else:
		assert(false, "Not a supported shape")
	
func find_closest_surface_point(position: Vector3) -> Vector3:
	# Help me get merged! https://github.com/godotengine/godot-proposals/issues/5218
	var p := global_transform.affine_inverse() * position
	
	if inner_shape.shape is CapsuleShape3D:
		var shape := inner_shape.shape as CapsuleShape3D
		return global_transform * find_closest_surface_point_capsule(p, shape)
	# TODO Support for other shapes
	else:
		assert(false, "Not a supported shape.")
		return Vector3.ZERO

func find_closest_surface_point_capsule(p: Vector3, shape: CapsuleShape3D) -> Vector3:
	# shape.height = line_length + 2 x shape.radius
	var half_line_length = (shape.height - shape.radius * 2) / 2
	# This is the position on the line that is closest to p
	var nearest_line_loc := Vector3(0, clamp(p.y, -half_line_length, half_line_length), 0);
	# Go from the nearest location on the line outwards by radius
	return nearest_line_loc + (p - nearest_line_loc).normalized() * shape.radius

func get_acceleration_at(position: Vector3) -> Vector3:
	var collision_point := find_closest_surface_point(position)
	print(collision_point, position)
	
	var difference := collision_point - position
	var distance := difference.length()
	return difference / distance * falloff_model.get_acceleration_at_distance(distance)
