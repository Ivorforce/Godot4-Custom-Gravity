extends Spatial

onready var _balance_point: BalancePoint = $"../BalancePoint"

func _ready () -> void:
	set_as_toplevel(true)

func _process (_delta: float) -> void:
	var balance_down := _balance_point.down
	var camera_down := -transform.basis.y

	var ortho_vector = balance_down.cross(camera_down).normalized()
	var angle = -balance_down.angle_to(camera_down)

	# Rotate the camera such that down is equal to the balance's down.
	# This is the rotation of least effort, which also makes it the least confusing.
	transform.basis = transform.basis.rotated(ortho_vector, angle)
	transform.origin = _balance_point.global_transform.origin
