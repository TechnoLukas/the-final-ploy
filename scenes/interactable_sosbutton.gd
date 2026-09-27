extends Area3D

var is_pressing = false
var pressed_pos = Vector3(-0.025,0,0)
@export var button_obj : Node3D

func _process(delta: float) -> void:
	if is_pressing: 
		#button_obj.position = pressed_pos
		button_obj.position = button_obj.position.slerp(pressed_pos, 8.0 * delta)
	else:
		#button_obj.position = Vector3(0,0,0)
		button_obj.position = button_obj.position.slerp(Vector3(0,0,0), 8.0 * delta)

func _on_lefthand_grab(grabber_transform: Transform3D) -> void:
	pass

func _lefthand_grabbing(grabber_transform: Transform3D) -> void:
	pass
		
func _on_lefthand_release() -> void:
	is_pressing = false	
	
	
func _on_righthand_grab(grabber_transform: Transform3D) -> void:
	pass
	
func _righthand_grabbing(grabber_transform: Transform3D) -> void:
	pass

func _on_righthand_release() -> void:
	pass

func _on_righthand_pressed() -> void:
	pass

func _on_lefthand_pressed() -> void:
	if owner.sosbuttonshield_value_degrees > 40 and owner.is_sos_available:
		is_pressing = true
		owner.button_click_sound.playing = true
	
