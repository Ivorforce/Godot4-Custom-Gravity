extends Node3D

@export var gravity_cutoff = 0.01

@onready var bounding_shape: CollisionShape3D = $BoundingShape
@onready var falloff_model = $FalloffModel

func _ready():
	reconfigure_from_params();

func reconfigure_from_params():
	falloff_model.reconfigure_from_params()
	
	# gravity_cutoff = a / (cutoff_distance - b)^2
	var cutoff_distance = falloff_model.get_distance_for_acceleration(gravity_cutoff)
	(bounding_shape.shape as SphereShape3D).radius = cutoff_distance

func get_acceleration_at(position: Vector3) -> Vector3:
	var difference = global_transform.origin - position
	var distance = difference.length()
	return difference / distance * falloff_model.get_acceleration_at_distance(distance)
