class_name BalancePoint extends Spatial

export var default_direction := Vector3.DOWN
export var default_gravity := 9.81

var main_gravitational_pull: GravityWell

func _ready():
	main_gravitational_pull = get_tree().get_root().find_node("GravityWell", true, false)

func get_down() -> Vector3:
	if main_gravitational_pull == null:
		return default_direction
	
	return global_transform.origin \
		.direction_to(main_gravitational_pull.global_transform.origin) \

func get_acceleration() -> Vector3:
	if main_gravitational_pull == null:
		return default_gravity * default_direction
	
	return main_gravitational_pull.get_acceleration_at(global_transform.origin)
