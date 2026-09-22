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
	initial_yoke_bone_pose_rot = skeleton3d.get_bone_pose_rotation(bone_yoke_idx)
	var yoke_bone_global_pos = skeleton3d.global_transform * skeleton3d.get_bone_global_pose(bone_yoke_idx).origin
	var yoke2hand_dir_world = (grabber_position - yoke_bone_global_pos).normalized()
	initial_yoke2hand_dir_local = skeleton3d.global_transform.basis.inverse() * yoke2hand_dir_world
	var yoke_proj_on_axis = initial_yoke2hand_dir_local.project(initial_yoke_bone_pose_rot * Vector3.UP)
	init_yoke2hand_proj = (initial_yoke2hand_dir_local - yoke_proj_on_axis).normalized()
	
	# COLLUMN ROTATION
	initial_collumn_bone_pose_rot = skeleton3d.get_bone_pose_rotation(bone_collumn_idx)
	var collumn_bone_global_pos = skeleton3d.global_transform * skeleton3d.get_bone_global_pose(bone_collumn_idx).origin
	var collumn2hand_dir_world = (grabber_position - collumn_bone_global_pos).normalized()
	initial_collumn2hand_dir_local = skeleton3d.global_transform.basis.inverse() * collumn2hand_dir_world
	var collumn_proj_on_axis = initial_collumn2hand_dir_local.project(initial_collumn_bone_pose_rot * Vector3.RIGHT)
	init_collumn2hand_proj = (initial_collumn2hand_dir_local - collumn_proj_on_axis).normalized()

func _grabbing(grabber_position: Vector3) -> void:
	# YOKE ROTATION
	var yoke_bone_global_pos = skeleton3d.global_transform * skeleton3d.get_bone_global_pose(bone_yoke_idx).origin
	var yoke2hand_dir_world = (grabber_position - yoke_bone_global_pos).normalized()
	var current_yoke2hand_dir_local = skeleton3d.global_transform.basis.inverse() * yoke2hand_dir_world

	var local_roll_axis = initial_yoke_bone_pose_rot * Vector3.UP
	var proj_on_axis = current_yoke2hand_dir_local.project(local_roll_axis)
	var curr_yoke2hand_proj = (current_yoke2hand_dir_local - proj_on_axis).normalized()
	var yoke_y_angle = init_yoke2hand_proj.signed_angle_to(curr_yoke2hand_proj, local_roll_axis)
	var yoke_y_rot_diff = Quaternion(Vector3.UP, yoke_y_angle)

	var yoke_target_pose_rot = (initial_yoke_bone_pose_rot * yoke_y_rot_diff).normalized()
	skeleton3d.set_bone_pose_rotation(bone_yoke_idx, yoke_target_pose_rot)
	
	mylable.text = str(rad_to_deg(skeleton3d.get_bone_pose_rotation(bone_yoke_idx).get_euler().y))
	
	# COLLUMN ROTATION
	var collumn_bone_global_pos = skeleton3d.global_transform * skeleton3d.get_bone_global_pose(bone_collumn_idx).origin
	
	var angle: float = skeleton3d.get_bone_pose_rotation(2).get_euler().y
	var rotated_grabber = yoke_bone_global_pos + ((grabber_position - yoke_bone_global_pos).rotated(Vector3(1.0,0.0,0.0), -angle))
	$CSGSphere3D.global_position = grabber_position
	$CSGSphere3D2.global_position = rotated_grabber
	print("Angle: ",rad_to_deg(angle))
	
	var collumn2hand_dir_world = (grabber_position - collumn_bone_global_pos).normalized()
	var current_collumn2hand_dir_local = skeleton3d.global_transform.basis.inverse() * collumn2hand_dir_world
	
	var cl_local_roll_axis = initial_collumn_bone_pose_rot * Vector3.RIGHT
	var cl_proj_on_axis = current_collumn2hand_dir_local.project(cl_local_roll_axis)
	var curr_collumn2hand_proj = (current_collumn2hand_dir_local - cl_proj_on_axis).normalized()
	var collumn_x_angle = init_collumn2hand_proj.signed_angle_to(curr_collumn2hand_proj, cl_local_roll_axis)
	var collumn_x_rot_diff = Quaternion(Vector3.RIGHT, collumn_x_angle)
	
	var collumn_target_pose_rot = (initial_collumn_bone_pose_rot * collumn_x_rot_diff).normalized()
	skeleton3d.set_bone_pose_rotation(bone_collumn_idx, collumn_target_pose_rot)
	
	
	

func _on_release() -> void:
	pass
	
