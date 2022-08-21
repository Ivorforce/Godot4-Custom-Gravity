class_name GravityShaped extends Spatial

export var start_radius = 1.0
export var half_falloff_offset = 10
export var max_acceleration = 9.81

export var gravity_cutoff = 0.01

onready var collision_body: CollisionObject = $".."
onready var influence_shape: CollisionShape = $InfluenceShape

# g = b / (d - a)^2
var _a;
var _b;

func _ready():
	reconfigure_from_params();

func reconfigure_from_params():
	var half_falloff_radius = start_radius + half_falloff_offset
	
	# 1 = b / (start - a)^2
	# 0.5 = b / (halfway - a)^2
	_a = (start_radius - sqrt(0.5) * half_falloff_radius) / (1 - sqrt(0.5))
	_b = pow(start_radius - _a, 2);
	
	# gravity_cutoff = a / (cutoff_distance - b)^2
	var cutoff_distance = sqrt(abs(_a) / gravity_cutoff) + _b
	influence_shape.scale = Vector3(cutoff_distance, cutoff_distance, cutoff_distance)

func get_acceleration_at_distance(distance: float) -> float:
	var adjusted_distance = max(0.001, distance - _a)
	var influence = min(1, _b / (adjusted_distance * adjusted_distance))
	return influence * max_acceleration

func intersect_ray_only(from: Vector3, to: Vector3, objects: Array) -> Dictionary:
	var one_off_layer := 1 << 31
	
	for object in objects:
		object.collision_layer |= one_off_layer
		
	var intersection := get_world().direct_space_state.intersect_ray(from, to, [], one_off_layer, true, true)

	for object in objects:
		object.collision_layer ^= one_off_layer

	return intersection

func get_acceleration_at(position: Vector3) -> Vector3:
	# FIXME What this really needs is a signed distance function. See: https://github.com/godotengine/godot-proposals/issues/5218
	var collision := intersect_ray_only(position, global_transform.origin, [collision_body])
	
	var difference := (collision['position'] as Vector3) - position
	var distance := difference.length()
	return difference / distance * get_acceleration_at_distance(distance)
