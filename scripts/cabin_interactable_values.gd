extends Node3D

@export var throttle_value : float
@export var throttle_value_degrees : float
@export var yoke_angle_value : float
@export var yoke_angle_value_degrees : float
@export var yokecollumn_angle_value : float
@export var yokecollumn_angle_value_degrees : float

@export var altitude_indicator_pitch : Node3D
@export var altitude_indicator_roll : Node3D
@export var alind_pitch_value : float

@onready var engine_sound = $Sound/AudioStreamPlayer3D
@onready var engine_sound2 = $Sound/AudioStreamPlayer3D2
@onready var engine_sound3 = $Sound/AudioStreamPlayer3D3

@export_group("Transition Settings")
@export var change_interval: float = 0.4
@export var lerp_speed: float = 4.0
@onready var min_linear: float = db_to_linear(-40.0)
@onready var max_linear: float = db_to_linear(-20.0)

var target_volume: float = min_linear
var current_volume: float = min_linear
var timer: float = 0.0


func _ready() -> void:
	current_volume = randf_range(min_linear, max_linear)
	target_volume = current_volume
	await get_tree().create_timer(1.0).timeout # Waiting the scene to actualy visualise on playerside and only then play
	engine_sound.play()
	engine_sound2.play()
	engine_sound3.play()
	#SetupXr.xr_interface.session_begun.connect(_on_xr_session_begun)

func _enter_tree() -> void:
	pass
	#engine_sound.play()
	#engine_sound2.play()
	#engine_sound3.play()

func _process(delta: float) -> void:
	$ThrottleManu/Label3D.text = str(roundf(throttle_value_degrees)) + "\n" + str(roundf(yoke_angle_value_degrees)) + "\n" + str(roundf(yokecollumn_angle_value_degrees))
	altitude_indicator_pitch.position.y = yokecollumn_angle_value * alind_pitch_value
	altitude_indicator_roll.rotation_degrees.z = yoke_angle_value_degrees
	
	
	timer -= delta
	
	if timer <= 0.0:
		target_volume = randf_range(min_linear, max_linear)
		timer = change_interval
	
	current_volume = lerp(current_volume, target_volume, lerp_speed * delta)
	engine_sound.volume_db = linear_to_db(max(current_volume, 0.0001))
	engine_sound.pitch_scale =  max(abs(throttle_value), 0.001) * 2.0
	engine_sound2.pitch_scale =  max(abs(throttle_value), 0.001) * 0.9
	engine_sound3.pitch_scale =  max(abs(minf(yoke_angle_value + yokecollumn_angle_value, 1.0)), 0.001) * 0.6
