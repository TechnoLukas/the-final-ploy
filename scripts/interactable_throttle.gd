extends Area3D

@export var skeleton3d: Skeleton3D

var bone_yoke_idx: int = 0
var initial_yoke2hand_dir_local: Vector3
var initial_yoke_bone_pose_rot: Quaternion
var init_yoke2hand_proj : Vector3
@onready var rest_yoke_pose_rot = skeleton3d.get_bone_pose_rotation(bone_yoke_idx)

@export var yoke_angle_limit : float = 45.0

func _on_lefthand_grab(grabber_transform: Transform3D) -> void:
	# YOKE ROTATION
	initial_yoke_bone_pose_rot = skeleton3d.get_bone_pose_rotation(bone_yoke_idx)
	var yoke_bone_global_pos = skeleton3d.global_transform * skeleton3d.get_bone_global_pose(bone_yoke_idx).origin
	var yoke2hand_dir_world = (grabber_transform.origin - yoke_bone_global_pos).normalized()
	initial_yoke2hand_dir_local = skeleton3d.global_transform.basis.inverse() * yoke2hand_dir_world
	var yoke_proj_on_axis = initial_yoke2hand_dir_local.project(initial_yoke_bone_pose_rot * Vector3.RIGHT)
	init_yoke2hand_proj = (initial_yoke2hand_dir_local - yoke_proj_on_axis).normalized()

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
	var yoke_angle_clamped = clamp(yoke_angle_raw, deg_to_rad(-yoke_angle_limit), deg_to_rad(yoke_angle_limit))
	var yoke_target_pose_rot_clamped = rest_yoke_pose_rot * Quaternion(Vector3.RIGHT, yoke_angle_clamped)
	skeleton3d.set_bone_pose_rotation(bone_yoke_idx, yoke_target_pose_rot_clamped)	
	
	var throttle_value_mapped = clampf(remap(yoke_target_pose_rot_clamped.get_euler().x, deg_to_rad(-yoke_angle_limit), deg_to_rad(yoke_angle_limit), 1.0, -1.0), -1.0, 1.0)
	owner.throttle_value = throttle_value_mapped
		
func _on_lefthand_release() -> void:
	pass	
	
	
func _on_righthand_grab(grabber_transform: Transform3D) -> void:
	_on_lefthand_grab(grabber_transform)
	pass
	
func _righthand_grabbing(grabber_transform: Transform3D) -> void:
	pass

func _on_righthand_release() -> void:
	pass



	
