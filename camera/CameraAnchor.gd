class_name CameraAnchor
extends Node3D

var target_down: Vector3 = Vector3.DOWN
var target_origin: Vector3 = Vector3.ZERO
var adjust_radians_per_second = 0.1

func _ready () -> void:
	set_as_top_level(true)

func _physics_process(delta: float) -> void:
	transform.origin = transform.origin.lerp(target_origin, delta * 50)

	var camera_down := -transform.basis.y

	var ortho_vector = target_down.cross(camera_down).normalized()
	if not ortho_vector.is_normalized():
		return  # We are equal (enough to not have a cross vector)

	var angle = min(-adjust_radians_per_second * delta, -target_down.angle_to(camera_down))
	# Rotate the camera such that down is equal to the balance's down.
	# This is the rotation of least effort, which also makes it the least confusing.
	transform.basis = transform.basis.rotated(ortho_vector, angle)
