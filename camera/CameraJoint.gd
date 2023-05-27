extends Node3D

@export var mouse_sensitivity := 0.05
@export var pitch_range := Vector2(-80.0, -10.0)

func _ready () -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	rotation_degrees.x = pitch_range.x / 5 * 4 + pitch_range.y / 5 * 1
		
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotation_degrees.x -= event.relative.y * mouse_sensitivity
		rotation_degrees.x = clamp(rotation_degrees.x, pitch_range.x, pitch_range.y)
		
		rotation_degrees.y -= event.relative.x * mouse_sensitivity
		rotation_degrees.y = wrapf(rotation_degrees.y, 0.0, 360.0)
