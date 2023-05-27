extends CharacterBody3D

@export var speed := 12.0
@export var jump_strength := 4.0

@export var velocity_control_floor := 50.0
@export var velocity_control_air := 5.0

@export var torque_control_floor := 10.0
@export var torque_control_air := 1.0

var _velocity := Vector3.ZERO

@onready var _balance_point: BalancePoint = $BalancePoint
@onready var _camera_anchor: CameraAnchor = $CameraAnchor

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
	
	_camera_anchor.target_origin = _balance_point.global_transform.origin
	
	if acceleration == Vector3.ZERO:
		# Weeee floating in free space!
		# Move tick
		set_velocity(_velocity)
		set_up_direction(Vector3.UP)
		set_floor_stop_on_slope_enabled(true)
		move_and_slide()
		_velocity = velocity
		return
	
	var movement_intention := get_movement_intention(
		get_viewport().get_camera_3d().global_transform.basis,
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
	set_velocity(_velocity)
	# TODOConverter40 looks that snap in Godot 4.0 is float, not vector like in Godot 3 - previous value `snap_vector`
	set_up_direction(up)
	set_floor_stop_on_slope_enabled(true)
	move_and_slide()
	_velocity = velocity
	
	var look_intention_horizontal
	if movement_intention != Vector3.ZERO:
		look_intention_horizontal = movement_intention
	else:
		look_intention_horizontal = -transform.basis.z
		# Delete "up" component; we want to look straight at the horizon
		look_intention_horizontal -= look_intention_horizontal.project(up)
	
	# Basis.looking_at is currently not exposed :(
	var look_intention := Transform3D.IDENTITY.looking_at(look_intention_horizontal, up).basis
	transform = Transform3D(
		transform.basis.slerp(look_intention, current_torque_control * delta).orthonormalized(),
		transform.origin
	)
	
	_camera_anchor.target_down = down

