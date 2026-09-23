extends Area3D

@export var skeleton3d: Skeleton3D

var bone_yoke_idx: int = 1
var initial_yoke2hand_dir_local: Vector3
var initial_yoke_bone_pose_rot: Quaternion
var init_yoke2hand_proj : Vector3
@onready var rest_yoke_pose_rot = skeleton3d.get_bone_pose_rotation(bone_yoke_idx)

var smoothed_point : Vector3 # When player roates a hand around imaginary pivot, this pivot shakes like crazy, so we need to smoothen it. 
var smoothed_point_local : Vector3
var bone_collumn_idx: int = 0
var initial_collumn2hand_dir_local: Vector3
var initial_collumn_bone_pose_rot: Quaternion
var init_collumn2hand_proj : Vector3
@onready var rest_collumn_pose_rot = skeleton3d.get_bone_pose_rotation(bone_collumn_idx)

@export var yoke_angle_limit : float = 45.0
@export var collumn_angle_limit : float = 10.0

@onready var mylable = $Label3D	

func _on_righthand_grab(grabber_transform: Transform3D) -> void:
	# YOKE ROTATION
	initial_yoke_bone_pose_rot = skeleton3d.get_bone_pose_rotation(bone_yoke_idx)
	var yoke_bone_global_pos = skeleton3d.global_transform * skeleton3d.get_bone_global_pose(bone_yoke_idx).origin
	var yoke2hand_dir_world = (grabber_transform.origin - yoke_bone_global_pos).normalized()
	initial_yoke2hand_dir_local = skeleton3d.global_transform.basis.inverse() * yoke2hand_dir_world
	var yoke_proj_on_axis = initial_yoke2hand_dir_local.project(initial_yoke_bone_pose_rot * Vector3.UP)
	init_yoke2hand_proj = (initial_yoke2hand_dir_local - yoke_proj_on_axis).normalized()
	
	# COLLUMN ROTATION
	var target_world: Vector3 = grabber_transform.origin + grabber_transform.basis.z.normalized() * 0.15
	smoothed_point_local = skeleton3d.global_transform.affine_inverse() * target_world
	smoothed_point = target_world
	
	initial_collumn_bone_pose_rot = skeleton3d.get_bone_pose_rotation(bone_collumn_idx)
	var collumn_bone_global_pos = skeleton3d.global_transform * skeleton3d.get_bone_global_pose(bone_collumn_idx).origin
	var collumn2hand_dir_world = (smoothed_point - collumn_bone_global_pos).normalized()
	initial_collumn2hand_dir_local = skeleton3d.global_transform.basis.inverse() * collumn2hand_dir_world
	var collumn_proj_on_axis = initial_collumn2hand_dir_local.project(initial_collumn_bone_pose_rot * Vector3.RIGHT)
	init_collumn2hand_proj = (initial_collumn2hand_dir_local - collumn_proj_on_axis).normalized()

func _righthand_grabbing(grabber_transform: Transform3D) -> void:
	# YOKE ROTATION
	var yoke_bone_global_pos = skeleton3d.global_transform * skeleton3d.get_bone_global_pose(bone_yoke_idx).origin
	var yoke2hand_dir_world = (grabber_transform.origin - yoke_bone_global_pos).normalized()
	var current_yoke2hand_dir_local = skeleton3d.global_transform.basis.inverse() * yoke2hand_dir_world

	var local_roll_axis = initial_yoke_bone_pose_rot * Vector3.UP
	var proj_on_axis = current_yoke2hand_dir_local.project(local_roll_axis)
	var curr_yoke2hand_proj = (current_yoke2hand_dir_local - proj_on_axis).normalized()
	var yoke_y_angle = init_yoke2hand_proj.signed_angle_to(curr_yoke2hand_proj, local_roll_axis)
	var yoke_y_rot_diff = Quaternion(Vector3.UP, yoke_y_angle)
	
	var yoke_target_pose_rot_raw = (initial_yoke_bone_pose_rot * yoke_y_rot_diff).normalized()
	var yoke_rel_rot_from_rest = rest_yoke_pose_rot.inverse() * yoke_target_pose_rot_raw
	var yoke_angle_raw = yoke_rel_rot_from_rest.get_euler().y
	var yoke_angle_clamped = clamp(yoke_angle_raw, deg_to_rad(-yoke_angle_limit), deg_to_rad(yoke_angle_limit))
	var yoke_target_pose_rot_clamped = rest_yoke_pose_rot * Quaternion(Vector3.UP, yoke_angle_clamped)
	skeleton3d.set_bone_pose_rotation(bone_yoke_idx, yoke_target_pose_rot_clamped)
	
	var yoke_rel = rest_yoke_pose_rot.inverse() * skeleton3d.get_bone_pose_rotation(bone_yoke_idx)
	var yoke_mes = rad_to_deg(yoke_rel.get_angle() * yoke_rel.get_axis().dot(Vector3.UP))
	var yoke_angle_value_mapped = -clampf(yoke_mes, -yoke_angle_limit, yoke_angle_limit)
	owner.yoke_angle_value = yoke_angle_value_mapped
	
	# COLLUMN ROTATION
	var point_above_world: Vector3 = grabber_transform.origin + grabber_transform.basis.z.normalized() * 0.15
	var point_above_local: Vector3 = skeleton3d.global_transform.affine_inverse() * point_above_world
	var distance: float = smoothed_point_local.distance_to(point_above_local)
	var dynamic_speed: float = 2.5 + (distance * 1000.0)
	var weight: float = clamp(dynamic_speed * get_process_delta_time(), 0.0, 1.0)
	smoothed_point_local = smoothed_point_local.lerp(point_above_local, weight)
	smoothed_point = skeleton3d.global_transform * smoothed_point_local

	var collumn_bone_global_pos = skeleton3d.global_transform * skeleton3d.get_bone_global_pose(bone_collumn_idx).origin	
	var collumn2hand_dir_world = (smoothed_point - collumn_bone_global_pos).normalized()
	var current_collumn2hand_dir_local = skeleton3d.global_transform.basis.inverse() * collumn2hand_dir_world
	
	var cl_local_roll_axis = initial_collumn_bone_pose_rot * Vector3.RIGHT
	var cl_proj_on_axis = current_collumn2hand_dir_local.project(cl_local_roll_axis)
	var curr_collumn2hand_proj = (current_collumn2hand_dir_local - cl_proj_on_axis).normalized()
	var collumn_x_angle = init_collumn2hand_proj.signed_angle_to(curr_collumn2hand_proj, cl_local_roll_axis)
	var collumn_x_rot_diff = Quaternion(Vector3.RIGHT, collumn_x_angle)
	
	var collumn_target_pose_rot_raw = (initial_collumn_bone_pose_rot * collumn_x_rot_diff).normalized()
	var collumn_rel_rot_from_rest = rest_collumn_pose_rot.inverse() * collumn_target_pose_rot_raw
	var collumn_angle_raw = collumn_rel_rot_from_rest.get_euler().x
	var collumn_angle_clamped = clamp(collumn_angle_raw, deg_to_rad(-collumn_angle_limit), deg_to_rad(collumn_angle_limit))
	var collumn_target_pose_rot_clamped = rest_collumn_pose_rot * Quaternion(Vector3.RIGHT, collumn_angle_clamped)
	skeleton3d.set_bone_pose_rotation(bone_collumn_idx, collumn_target_pose_rot_clamped)
	
	var collumn_rot = rest_collumn_pose_rot.inverse() * skeleton3d.get_bone_pose_rotation(bone_collumn_idx)
	var collumn_mes = rad_to_deg(collumn_rot.get_angle() * collumn_rot.get_axis().dot(Vector3.RIGHT))
	var yokecollumn_angle_value_mapped = -clampf(collumn_mes, -collumn_angle_limit, collumn_angle_limit)
	owner.yokecollumn_angle_value = yokecollumn_angle_value_mapped
	
	#clampf(remap(yoke_target_pose_rot_clamped.get_euler().x, deg_to_rad(-yoke_angle_limit), deg_to_rad(yoke_angle_limit), 1.0, -1.0), -1.0, 1.0)
	owner.yokecollumn_angle_value = yokecollumn_angle_value_mapped
	

func _on_righthand_release() -> void:
	pass
	
func _on_lefthand_grab(grabber_transform: Transform3D) -> void:
	_on_righthand_grab(grabber_transform)
	
func _lefthand_grabbing(grabber_transform: Transform3D) -> void:
	_righthand_grabbing(grabber_transform)
		
func _on_lefthand_release() -> void:
	pass	
