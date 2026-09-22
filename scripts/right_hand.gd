extends XRNode3D

# Drag and drop your child detector node into this variable
@onready var hand_pose_detector = $HandPoseDetector
@export var hand_fist_area : Area3D

@onready var log_list = $"../XRCamera3D/MeshInstance3D/SubViewport/HBoxContainer"

var is_grabbed = false
var obj_grabbed

func _ready():
	hand_pose_detector.pose_started.connect(_on_hand_pose_detected)
	hand_pose_detector.pose_ended.connect(_on_hand_pose_released)
	hand_fist_area.area_exited.connect(obj_released)

func _process(delta: float) -> void:
	if is_grabbed:
		obj_grabbed._grabbing(global_position)

func _on_hand_pose_detected(pose_name: String):
	if pose_name == "Fist":
		print("Fist")
		print(hand_fist_area.get_overlapping_areas())
		var interactable 
		for obj in hand_fist_area.get_overlapping_areas():
			if "INTERACTABLE" in obj.name:
				interactable = obj 
		if interactable:
			is_grabbed = true
			obj_grabbed = interactable
			interactable._on_grab(global_position)

func _on_hand_pose_released(pose_name: String):
	if pose_name == "Fist":
		print("Released Fist")
		if is_grabbed:
			is_grabbed = false
			obj_grabbed._on_release()
			obj_grabbed = null
			
func obj_released(area: Area3D):
	if area == obj_grabbed:
		is_grabbed = false
		obj_grabbed._on_release()
		obj_grabbed = null
