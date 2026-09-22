extends XRNode3D

# Drag and drop your child detector node into this variable
@onready var hand_pose_detector = $HandPoseDetector
@export var hand_fist_shapecast : ShapeCast3D

@onready var log_list = $"../XRCamera3D/MeshInstance3D/SubViewport/HBoxContainer"

var yoke_grabbed = false
var yoke_initial_hand_angle
var yoke_initial_angle
var yoke_obj : Area3D

func _ready():
	hand_pose_detector.pose_started.connect(_on_hand_pose_detected)
	hand_pose_detector.pose_ended.connect(_on_hand_pose_released)

func _process(delta: float) -> void:
	if yoke_grabbed:
		process_steering()

func _on_hand_pose_detected(pose_name: String):
	if pose_name == "Fist":
		print("Fist")
		logprint("Fist")
		if hand_fist_shapecast.get_collider(0):
			if "INTERACTABLE" in hand_fist_shapecast.get_collider(0).name:
				print(hand_fist_shapecast.get_collision_count(), hand_fist_shapecast.get_collider(0))
				logprint([hand_fist_shapecast.get_collision_count(), " ", hand_fist_shapecast.get_collider(0)])
				
				_on_hand_grabbed()

func _on_hand_pose_released(pose_name: String):
	if pose_name == "Fist":
		print("Released Fist")
		logprint("Released Fist")
		_on_hand_released()
		
func _on_hand_grabbed():
	yoke_grabbed = true
	yoke_obj = hand_fist_shapecast.get_collider(0)
	yoke_initial_hand_angle = get_local_angle_to_hand()
	yoke_initial_angle = yoke_obj.rotation.z
	logprint(yoke_initial_hand_angle, " ", yoke_initial_angle)
	
func _on_hand_released():
	yoke_grabbed = false
	yoke_initial_hand_angle = 0.0
	yoke_initial_angle = 0.0
	yoke_obj = null
	
func process_steering():
	var current_hand_angle = get_local_angle_to_hand()
	var angle_diff = angle_difference(yoke_initial_hand_angle, current_hand_angle)
	var target_rotation = yoke_initial_angle + angle_diff
	yoke_obj.rotation.z = lerp_angle(yoke_obj.rotation.z, target_rotation, 0.25)

func get_local_angle_to_hand() -> float:
	#var local_hand_pos = global_position - yoke_obj.global_position
	#return atan2(local_hand_pos.y, local_hand_pos.x)
	return (global_position - yoke_obj.global_position).signed_angle_to(Vector3.RIGHT, Vector3.FORWARD)

func logprint(...args) -> void:
	var logstr = ""
	var first_child : Label = log_list.get_child(0)
	var duplicate_child = first_child.duplicate()
	for m in args:
		logstr += str(m)
	duplicate_child.text = str(logstr)
	duplicate_child.visible=true
	log_list.add_child(duplicate_child)
