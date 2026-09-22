extends XROrigin3D

@onready var xr_camera: XRCamera3D = $XRCamera3D
@export var target_object: Node3D

func _ready() -> void:
	await get_tree().process_frame
	if SetupXr.xr_interface:
		SetupXr.xr_interface.pose_recentered.connect(recenter)
	recenter()

func recenter() -> void:
	if not target_object or not xr_camera:
		return

	XRServer.center_on_hmd(XRServer.RESET_BUT_KEEP_TILT, true)

	await get_tree().process_frame
	await get_tree().process_frame # if done only once, it doesn't work LOL
	
	var head_pos := xr_camera.global_position
	var desired_dir := target_object.global_position - head_pos
	desired_dir.y = 0.0
	var current_dir := -xr_camera.global_transform.basis.z
	current_dir.y = 0.0

	var angle_diff := current_dir.normalized().signed_angle_to(desired_dir.normalized(), Vector3.UP)
	var cam_offset := head_pos - global_position
	cam_offset.y = 0.0
	rotate_y(angle_diff)
	global_position += cam_offset - cam_offset.rotated(Vector3.UP, angle_diff)

	
	var height_diff := target_object.global_position.y - xr_camera.global_position.y
	global_position.y += height_diff
