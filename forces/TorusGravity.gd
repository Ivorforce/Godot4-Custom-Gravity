extends Node3D

# Need to copy most of ShapeGravity because TorusShape is not a real Shape object.
const TorusShape = preload("res://shapes/TorusShape.gd")

@export var gravity_cutoff = 0.01

# Can't export TorusShape because of https://github.com/godotengine/godot-proposals/issues/18
var inner_shape: TorusShape
@export var major_radius := 50
@export var minor_radius := 15

@onready var bounding_shape: CollisionShape3D = $BoundingShape
@onready var falloff_model = $FalloffModel

func _ready():
	inner_shape = TorusShape.new()

	inner_shape.major_radius = major_radius
	inner_shape.minor_radius = minor_radius
	
	reconfigure_from_params();

func reconfigure_from_params():
	falloff_model.reconfigure_from_params()
	
	# gravity_cutoff = a / (cutoff_distance - b)^2
	var cutoff_distance = falloff_model.get_distance_for_acceleration(gravity_cutoff)
	(bounding_shape.shape as SphereShape3D).radius = (inner_shape as TorusShape).major_radius + (inner_shape as TorusShape).minor_radius + cutoff_distance
	
func find_closest_surface_point(position: Vector3) -> Vector3:
	var p := global_transform.affine_inverse() * position
	return global_transform * find_closest_surface_point_torus(p, inner_shape as TorusShape)

func find_closest_surface_point_torus(p: Vector3, shape: TorusShape) -> Vector3:
	var ring_position = Vector3(p.x, 0, p.z).normalized() * shape.major_radius
	return ring_position + (p - ring_position).normalized() * shape.minor_radius

func get_acceleration_at(position: Vector3) -> Vector3:
	var collision_point := find_closest_surface_point(position)
	
	var difference := collision_point - position
	var distance := difference.length()
	return difference / distance * falloff_model.get_acceleration_at_distance(distance)
