extends CharacterBody3D

@export var speed := 12.0
@export var jump_strength := 4.0

@export var velocity_control_floor := 50.0
@export var velocity_control_air := 5.0

@export var torque_control_floor := 10.0
@export var torque_control_air := 1.0

@onready var _balance_point: BalancePoint = $BalancePoint
@onready var _camera_anchor: CameraAnchor = $CameraAnchor


static func get_movement_input() -> Vector2:
	var vector := Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("back") - Input.get_action_strength("forward")
	)
	if vector.length_squared() > 1:
		return vector.normalized()  # e.g. keyboard input
	else:
		return vector


static func project_movement_intention(basis: Basis, up: Vector3, movement_input: Vector2) -> Vector3:
	if movement_input == Vector2.ZERO:
		return Vector3.ZERO

	movement_input = movement_input.normalized() * min(movement_input.length(), 1)

	var up_surface = -up.cross(basis.x).normalized()
	var right_surface = -up.cross(basis.y).normalized()
	
	return up_surface * movement_input.y + right_surface * movement_input.x


func _physics_process(delta: float) -> void:
	# Update where we are
	_camera_anchor.target_origin = _balance_point.global_transform.origin
		
	var acceleration := _balance_point.acceleration
	if acceleration == Vector3.ZERO:
		# Weeee floating in free space!
		move_and_slide()
		return
	
	# Because we have it, update where up / down is
	_camera_anchor.target_down = _balance_point.down
	set_up_direction(_balance_point.up)

	# What controls is the player inputting?
	var movement_input := get_movement_input()

	# Where does the player want to move?
	var movement_intention := project_movement_intention(
		get_viewport().get_camera_3d().global_transform.basis,
		_balance_point.up,
		movement_input
	)

	# How much control does the player get over the character?
	var current_velocity_control: float
	var current_torque_control: float
	if self.is_on_floor():
		current_velocity_control = velocity_control_floor
		current_torque_control = torque_control_floor
	else:
		current_velocity_control = velocity_control_air
		current_torque_control = torque_control_air
	
	# Jumping
	self._process_jumping()
	
	# Walking
	_process_walking(movement_intention, current_velocity_control * delta)
	
	# Forces acting on us
	velocity += acceleration * delta
	
	# Finally, we move!
	move_and_slide()
	
	# ... and turn
	_process_turning(movement_intention, current_torque_control * delta)


func _process_jumping():
	var up := _balance_point.up
	
	var is_jumping := self.is_on_floor() and Input.is_action_just_pressed( "jump")
	if is_jumping:
		velocity += up * jump_strength - velocity.project(up)


func _process_walking(movement_intention: Vector3, control: float):
	var up := _balance_point.up
	
	var desired_velocity_change := movement_intention * speed - velocity
	# Just in case: delete "up" component.
	# If we didn't do this, we would stay levitating in the air.
	desired_velocity_change -= desired_velocity_change.project(up)

	velocity = velocity.move_toward(
		velocity + desired_velocity_change,
		 control
	)


func _process_turning(movement_intention: Vector3, control: float):
	var forward := -transform.basis.z
	var up := _balance_point.up
	
	var look_intention_horizontal: Vector3
	if movement_intention != Vector3.ZERO:
		look_intention_horizontal = movement_intention
	else:
		# If the player provides no input, we want to turn forward, parallel to the floor.
		look_intention_horizontal = forward - forward.project(up)
	
	var look_intention := Basis.IDENTITY.looking_at(look_intention_horizontal, up)
	transform = Transform3D(
		transform.basis.slerp(look_intention, control).orthonormalized(),
		transform.origin
	)
