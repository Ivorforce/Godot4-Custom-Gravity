class_name GravityField extends Spatial

export var acceleration_vector = Vector3(1, 0, 0)

onready var collision_shape: CollisionShape = $CollisionShape

func get_acceleration_at(position: Vector3) -> Vector3:
	return acceleration_vector
