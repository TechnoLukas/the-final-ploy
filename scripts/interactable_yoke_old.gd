extends Area3D

@export var skeleton3d: Skeleton3D

var bone_yoke_idx: int = 1
var initial_yoke2hand_dir_local: Vector3
var initial_yoke_bone_pose_rot: Quaternion
var init_yoke2hand_proj : Vector3

var bone_collumn_idx: int = 0
var initial_collumn2hand_dir_local: Vector3
var initial_collumn_bone_pose_rot: Quaternion
var init_collumn2hand_proj : Vector3

@export var yoke_angle_limit : float = 45.0
@export var collumn_angle_limit : float = 10.0

@onready var mylable = $Label3D

func _on_grab(grabber_position: Vector3) -> void:
	# YOKE ROTATION
	var yoke_bone_global_pos = skeleton3d.global_transform * skeleton3d.get_bone_global_pose(bone_yoke_idx).origin
	var yoke2hand_dir_world = (grabber_position - yoke_bone_global_pos).normalized()
	
	initial_yoke2hand_dir_local = skeleton3d.global_transform.basis.inverse() * yoke2hand_dir_world
	init_yoke2hand_proj = Vector3(initial_yoke2hand_dir_local.x, initial_yoke2hand_dir_local.y, 0.0).normalized()
	initial_yoke_bone_pose_rot = skeleton3d.get_bone_pose_rotation(bone_yoke_idx)
	
	# COLLUMN ROTATION
	var collumn_bone_global_pos = skeleton3d.global_transform * skeleton3d.get_bone_global_pose(bone_collumn_idx).origin
	var collumn2hand_dir_world = (grabber_position - collumn_bone_global_pos).normalized()
	
	initial_collumn2hand_dir_local = skeleton3d.global_transform.basis.inverse() * collumn2hand_dir_world
	init_collumn2hand_proj = Vector3(0.0, initial_collumn2hand_dir_local.y, initial_collumn2hand_dir_local.z).normalized()
	initial_collumn_bone_pose_rot = skeleton3d.get_bone_pose_rotation(bone_collumn_idx)

func _grabbing(grabber_position: Vector3) -> void:
	# YOKE ROTATION
	var yoke_bone_global_pos = skeleton3d.global_transform * skeleton3d.get_bone_global_pose(bone_yoke_idx).origin
	var yoke2hand_dir_world = (grabber_position - yoke_bone_global_pos).normalized()
	var current_yoke2hand_dir_local = skeleton3d.global_transform.basis.inverse() * yoke2hand_dir_world

	var curr_yoke2hand_proj = Vector3(current_yoke2hand_dir_local.x, current_yoke2hand_dir_local.y, 0.0).normalized()

	var yoke_z_angle = init_yoke2hand_proj.signed_angle_to(curr_yoke2hand_proj, Vector3.FORWARD)
	#var yoke_z_angle_clamped = clamp(yoke_z_angle_raw, -deg_to_rad(90.0), deg_to_rad(90.0))
	#mylable.text = str(rad_to_deg(skeleton3d.get_bone_pose_rotation(bone_yoke_idx).get_euler().z))
	
	var yoke_z_rot_diff = Quaternion(Vector3.FORWARD, yoke_z_angle)

	var yoke_target_pose_rot_raw = (initial_yoke_bone_pose_rot * yoke_z_rot_diff).normalized()
	var yoke_euler = yoke_target_pose_rot_raw.get_euler()
	yoke_euler.z = clamp(yoke_euler.z, -deg_to_rad(yoke_angle_limit), deg_to_rad(yoke_angle_limit))
	var yoke_target_pose_rot_clamped = Quaternion.from_euler(yoke_euler)

	skeleton3d.set_bone_pose_rotation(bone_yoke_idx, yoke_target_pose_rot_clamped)
	
	# COLLUMN ROTATION
	var collumn_bone_global_pos = skeleton3d.global_transform * skeleton3d.get_bone_global_pose(bone_collumn_idx).origin
	var collumn2hand_dir_world = (grabber_position - collumn_bone_global_pos).normalized()
	var current_collumn2hand_dir_local = skeleton3d.global_transform.basis.inverse() * collumn2hand_dir_world
	
	var curr_collumn2hand_proj = Vector3(0.0, current_collumn2hand_dir_local.y, current_collumn2hand_dir_local.z).normalized()

	var collumn_x_angle = init_collumn2hand_proj.signed_angle_to(curr_collumn2hand_proj, Vector3.RIGHT)
	var collumn_x_rot_diff = Quaternion(Vector3.RIGHT, collumn_x_angle)
	
	var collumn_target_pose_rot_raw = (initial_collumn_bone_pose_rot * collumn_x_rot_diff).normalized()
	var collumn_euler = collumn_target_pose_rot_raw.get_euler()
	collumn_euler.x = clamp(collumn_euler.x, -deg_to_rad(collumn_angle_limit), deg_to_rad(collumn_angle_limit))
	var collumn_target_pose_rot_clamped = Quaternion.from_euler(collumn_euler)

	skeleton3d.set_bone_pose_rotation(bone_collumn_idx, collumn_target_pose_rot_clamped)
	mylable.text = str(rad_to_deg(skeleton3d.get_bone_pose_rotation(bone_collumn_idx).get_euler().x))
	

func _on_release() -> void:
	pass
	
