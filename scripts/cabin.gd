extends Node3D

@export var cabin_interactive_values: Node3D

@export var max_speed: float = 10.0
@export var turn_speed: float = 2.0 # Base turn speed in rad/s
@export var max_pitch_angle: float = deg_to_rad(30.0)
@export var max_roll_angle: float = deg_to_rad(20.0) # Small absolute roll limit

var throttle: float = 0.0
var steering_angle: float = 0.0

func _process(delta: float) -> void:
	throttle = cabin_interactive_values.throttle_value
	steering_angle = -cabin_interactive_values.yoke_angle_value
	var pitch_input = cabin_interactive_values.yokecollumn_angle_value # Value from -1.0 to 1.0

	# 1. Update yaw incrementally
	var current_turn_rate = turn_speed * steering_angle
	rotate_y(current_turn_rate * delta)

	# 2. Extract current heading (yaw)
	var current_yaw = rotation.y

	# 3. Calculate absolute targets for pitch and roll
	var target_pitch = pitch_input * max_pitch_angle
	# Roll banks into the turn (positive roll tilts left, negative tilts right in local Z)
	var target_roll = steering_angle * max_roll_angle

	# 4. Construct Basis applying Pitch (X), Yaw (Y), and Roll (Z)
	basis = Basis.from_euler(Vector3(target_pitch, current_yaw, target_roll), EULER_ORDER_YXZ)

	# 5. Translate forward along local Z
	var forward = -transform.basis.z
	global_position += forward * throttle * max_speed * delta
