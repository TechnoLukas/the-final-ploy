extends Node3D

@export var throttle_value : float
@export var yoke_angle_value : float
@export var yokecollumn_angle_value : float

func _process(delta: float) -> void:
	$ThrottleValue.text = str(throttle_value)
	$YokeAngleValue.text = str(yoke_angle_value)
	$YokecollumnAngleValue.text = str(yokecollumn_angle_value)
