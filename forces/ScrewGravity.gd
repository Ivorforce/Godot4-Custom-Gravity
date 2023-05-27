class_name ScrewGravity extends Node3D

@export var full_rotation_length := 1
@export var is_clockwise := true
@export var acceleration := 9.81

func get_acceleration_at(position: Vector3) -> Vector3:
	var p := global_transform.affine_inverse() * position
	var progression := p.z / full_rotation_length * 2 * PI
	
	if not is_clockwise:
		progression = -progression
	
	var gravity := Vector3.DOWN * cos(progression) + Vector3.RIGHT * sin(progression)

	return (global_transform.basis.get_rotation_quaternion() * gravity) * acceleration
