class_name CameraAnchor
extends Spatial

var target_down: Vector3 = Vector3.DOWN
var target_origin: Vector3 = Vector3.ZERO

func _ready () -> void:
	set_as_toplevel(true)

func _process (_delta: float) -> void:
	var camera_down := -transform.basis.y

	var ortho_vector = target_down.cross(camera_down).normalized()
	var angle = -target_down.angle_to(camera_down)

	# Rotate the camera such that down is equal to the balance's down.
	# This is the rotation of least effort, which also makes it the least confusing.
	transform.basis = transform.basis.rotated(ortho_vector, angle)
	transform.origin = target_origin
