extends KinematicBody

export var speed := 15.0
export var jump_strength := 5.0

export var velocity_control_floor := 50.0
export var velocity_control_air := 10.0

export var torque_control_floor := 10.0
export var torque_control_air := 1.0

var _velocity := Vector3.ZERO

onready var _balance_point: BalancePoint = $BalancePoint
onready var _camera_anchor: CameraAnchor = $CameraAnchor

static func get_movement_intention(basis: Basis, up: Vector3, vertical: float, horizontal: float) -> Vector3:
	if (abs(horizontal) + abs(vertical) < 0.01):
		return Vector3.ZERO

	var intention_2d = Vector2(horizontal, vertical)
	intention_2d = intention_2d.normalized() * min(intention_2d.length(), 1)

	var up_surface = -up.cross(basis.x).normalized()
	var right_surface = -up.cross(basis.y).normalized()
	
	return up_surface * intention_2d.y + right_surface * intention_2d.x

func _physics_process(delta: float) -> void:
	var acceleration := _balance_point.acceleration
	var down := _balance_point.down
	var up = _balance_point.up
	
	if acceleration == Vector3.ZERO:
		return  # Weeee floating in free space!
	
	var movement_intention := get_movement_intention(
		get_viewport().get_camera().global_transform.basis,
		up,
		Input.get_action_strength("back") - Input.get_action_strength("forward"),
		Input.get_action_strength("right") - Input.get_action_strength("left")
	)

	var is_on_floor := self.is_on_floor()

	var is_jumping : = is_on_floor and Input.is_action_just_pressed( "jump")
	var snap_vector = down
	
	if is_jumping:
		_velocity +=  up * jump_strength - _velocity.project(up)
		snap_vector = Vector3.ZERO
		
	var desired_velocity_change := movement_intention * speed - _velocity
	# Delete "up" component; we have no control over this
	desired_velocity_change -= desired_velocity_change.project(up)
	
	var current_velocity_control: float
	var current_torque_control: float
	if is_on_floor:
		current_velocity_control = velocity_control_floor
		current_torque_control = torque_control_floor
	else:
		current_velocity_control = velocity_control_air
		current_torque_control = torque_control_air
	
	# Walking
	_velocity = _velocity.move_toward(
		_velocity + desired_velocity_change,
		 current_velocity_control * delta
	)
	
	# Gravity
	_velocity += acceleration * delta
	
	# Move tick
	_velocity = move_and_slide_with_snap(_velocity, snap_vector, up, true)
	
	var look_intention_horizontal
	if movement_intention != Vector3.ZERO:
		look_intention_horizontal = movement_intention
	else:
		look_intention_horizontal = -transform.basis.z
		# Delete "up" component; we want to look straight at the horizon
		look_intention_horizontal -= look_intention_horizontal.project(up)
	
	# Basis.looking_at is currently not exposed :(
	var look_intention := Transform.IDENTITY.looking_at(look_intention_horizontal, up).basis
	transform = Transform(
		transform.basis.slerp(look_intention, current_torque_control * delta).orthonormalized(),
		transform.origin
	)
	
	_camera_anchor.target_down = down
	_camera_anchor.target_origin = _balance_point.global_transform.origin
