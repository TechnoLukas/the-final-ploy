extends Node3D

@export var throttle_value : float
@export var throttle_value_degrees : float
@export var yoke_angle_value : float
@export var yoke_angle_value_degrees : float
@export var yokecollumn_angle_value : float
@export var yokecollumn_angle_value_degrees : float

func _process(delta: float) -> void:
	#$ThrottleValue.text = str(throttle_value)
	#$YokeAngleValue.text = str(yoke_angle_value)
	#$YokecollumnAngleValue.text = str(yokecollumn_angle_value)
	
	$ThrottleManu/Label3D.text = str(roundf(throttle_value_degrees)) + "\n" + str(roundf(yoke_angle_value_degrees)) + "\n" + str(roundf(yokecollumn_angle_value_degrees))
	#$Debug/YokeAngleValue.text = str(roundf(yoke_angle_value_degrees))
