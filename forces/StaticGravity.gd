extends Node3D

@export var acceleration_vector = Vector3(1, 0, 0)

func get_acceleration_at(position: Vector3) -> Vector3:
	return acceleration_vector
