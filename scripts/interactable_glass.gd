extends Area3D

@export var skeleton3d: Skeleton3D

var bone_yoke_idx: int = 0
var initial_yoke2hand_dir_local: Vector3
var initial_yoke_bone_pose_rot: Quaternion
var init_yoke2hand_proj : Vector3
@onready var rest_yoke_pose_rot = skeleton3d.get_bone_pose_rotation(bone_yoke_idx)

@export var yoke_angle_limit_min : float = 45.0
@export var yoke_angle_limit_max : float = 45.0

func _on_lefthand_grab(grabber_transform: Transform3D) -> void:
	# YOKE ROTATION
	initial_yoke_bone_pose_rot = skeleton3d.get_bone_pose_rotation(bone_yoke_idx)
	var yoke_bone_global_pos = skeleton3d.global_transform * skeleton3d.get_bone_global_pose(bone_yoke_idx).origin
	var yoke2hand_dir_world = (grabber_transform.origin - yoke_bone_global_pos).normalized()
	initial_yoke2hand_dir_local = skeleton3d.global_transform.basis.inverse() * yoke2hand_dir_world
	var yoke_proj_on_axis = initial_yoke2hand_dir_local.project(initial_yoke_bone_pose_rot * Vector3.RIGHT)
	init_yoke2hand_proj = (initial_yoke2hand_dir_local - yoke_proj_on_axis).normalized()
	
	owner.sosbuttonshield_value_degrees = 90.0 + get_bone_rotation(bone_yoke_idx, rest_yoke_pose_rot, Vector3.RIGHT, yoke_angle_limit_min, yoke_angle_limit_max, false)

func _lefthand_grabbing(grabber_transform: Transform3D) -> void:
	# YOKE ROTATION
	var yoke_bone_global_pos = skeleton3d.global_transform * skeleton3d.get_bone_global_pose(bone_yoke_idx).origin
	var yoke2hand_dir_world = (grabber_transform.origin - yoke_bone_global_pos).normalized()
	var current_yoke2hand_dir_local = skeleton3d.global_transform.basis.inverse() * yoke2hand_dir_world

	var local_roll_axis = initial_yoke_bone_pose_rot * Vector3.RIGHT
	var proj_on_axis = current_yoke2hand_dir_local.project(local_roll_axis)
	var curr_yoke2hand_proj = (current_yoke2hand_dir_local - proj_on_axis).normalized()
	var yoke_y_angle = init_yoke2hand_proj.signed_angle_to(curr_yoke2hand_proj, local_roll_axis)
	var yoke_y_rot_diff = Quaternion(Vector3.RIGHT, yoke_y_angle)
	
	var yoke_target_pose_rot_raw = (initial_yoke_bone_pose_rot * yoke_y_rot_diff).normalized()
	var yoke_rel_rot_from_rest = rest_yoke_pose_rot.inverse() * yoke_target_pose_rot_raw
	var yoke_angle_raw = yoke_rel_rot_from_rest.get_angle() * yoke_rel_rot_from_rest.get_axis().dot(Vector3.RIGHT)
	if abs(yoke_angle_raw) < 0.025: yoke_angle_raw = 0.0
	var yoke_angle_clamped = clamp(yoke_angle_raw, deg_to_rad(yoke_angle_limit_min), deg_to_rad(yoke_angle_limit_max))
	var yoke_target_pose_rot_clamped = rest_yoke_pose_rot * Quaternion(Vector3.RIGHT, yoke_angle_clamped)
	skeleton3d.set_bone_pose_rotation(bone_yoke_idx, yoke_target_pose_rot_clamped)	
	
	owner.sosbuttonshield_value_degrees = 90.0 + get_bone_rotation(bone_yoke_idx, rest_yoke_pose_rot, Vector3.RIGHT, yoke_angle_limit_min, yoke_angle_limit_max, false)
	#owner.throttle_value_degrees = get_bone_rotation(bone_yoke_idx, rest_yoke_pose_rot, Vector3.RIGHT, yoke_angle_limit, false)
	
func get_bone_rotation(bone_idx, rest_pose_rot, vector, angle_limit_min, angle_limit_max, is_normalised):
	var bone_rot = rest_pose_rot.inverse() * skeleton3d.get_bone_pose_rotation(bone_idx)
	var component = bone_rot.x if vector == Vector3.RIGHT else (bone_rot.y if vector == Vector3.UP else bone_rot.z)
	var bone_mes = rad_to_deg(2.0 * atan2(component, bone_rot.w))
	var bone_angle_value_mapped
	if is_normalised:
		bone_angle_value_mapped = clampf(remap(bone_mes, yoke_angle_limit_min, yoke_angle_limit_max, 1.0, -1.0), -1.0, 1.0)
	else:
		bone_angle_value_mapped = clampf(remap(bone_mes, yoke_angle_limit_min, yoke_angle_limit_max, yoke_angle_limit_max, yoke_angle_limit_min), yoke_angle_limit_min, yoke_angle_limit_max)
	return bone_angle_value_mapped
	
		
func _on_lefthand_release() -> void:
	pass	
	
	
func _on_righthand_grab(grabber_transform: Transform3D) -> void:
	pass
	
func _righthand_grabbing(grabber_transform: Transform3D) -> void:
	pass

func _on_righthand_release() -> void:
	pass

func _on_righthand_pressed() -> void:
	pass

func _on_lefthand_pressed() -> void:
	pass
	
