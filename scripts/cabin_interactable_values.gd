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

@export var sosbuttonshield_value_degrees : float

@onready var engine_sound = $Sound/AudioStreamPlayer3D
@onready var engine_sound2 = $Sound/AudioStreamPlayer3D2
@onready var engine_sound3 = $Sound/AudioStreamPlayer3D3

@export var change_interval: float = 0.4
@export var lerp_speed: float = 4.0
@onready var min_linear: float = db_to_linear(-40.0)
@onready var max_linear: float = db_to_linear(-20.0)

var target_volume: float = min_linear
var current_volume: float = min_linear
var timer: float = 0.0

@export var sosbutton_shield : MeshInstance3D
@export var sosbutton : MeshInstance3D
@export var availabe_material : StandardMaterial3D
@export var unavailable_material : StandardMaterial3D
@export var sosbutton_shield_transparency = 0.53
@export var lable_available : Label3D
@export var lable_unavailable : Label3D

@export var is_sos_available = false

@export var button_click_sound : AudioStreamPlayer3D

func _ready() -> void:
	current_volume = randf_range(min_linear, max_linear)
	target_volume = current_volume
	await get_tree().create_timer(1.0).timeout # Waiting the scene to actualy visualise on playerside and only then play
	engine_sound.play()
	engine_sound2.play()
	engine_sound3.play()
	#SetupXr.xr_interface.session_begun.connect(_on_xr_session_begun)
	
	deactivate_sos_button()

func _enter_tree() -> void:
	pass
	#engine_sound.play()
	#engine_sound2.play()
	#engine_sound3.play()

func _process(delta: float) -> void:
	$ThrottleManu/Label3D.text = str(roundf(throttle_value_degrees)) + "\n" + str(roundf(yoke_angle_value_degrees)) + "\n" + str(roundf(yokecollumn_angle_value_degrees))
	altitude_indicator_pitch.position.y = yokecollumn_angle_value * alind_pitch_value
	altitude_indicator_roll.rotation_degrees.z = yoke_angle_value_degrees
	
	#print(sosbuttonshield_value_degrees)
	#$Debug/ThrottleValue.text = str(sosbuttonshield_value_degrees)
	
	timer -= delta
	
	if timer <= 0.0:
		target_volume = randf_range(min_linear, max_linear)
		timer = change_interval
	
	current_volume = lerp(current_volume, target_volume, lerp_speed * delta)
	engine_sound.volume_db = linear_to_db(max(current_volume, 0.0001))
	engine_sound.pitch_scale =  max(abs(throttle_value), 0.001) * 2.0
	engine_sound2.pitch_scale =  max(abs(throttle_value), 0.001) * 0.9
	engine_sound3.pitch_scale =  max(minf(abs(yoke_angle_value)*0.5 + abs(yokecollumn_angle_value)*0.5, 1.0), 0.001) * 0.6
	
func activate_sos_button():
	is_sos_available = true
	sosbutton.set_surface_override_material(0,availabe_material)
	var transp_material = availabe_material.duplicate()
	transp_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	transp_material.albedo_color.a = sosbutton_shield_transparency
	sosbutton_shield.set_surface_override_material(0,transp_material)
	lable_available.visible = true
	lable_unavailable.visible = false
	
	
func deactivate_sos_button():
	is_sos_available = false
	sosbutton.set_surface_override_material(0,unavailable_material)
	var transp_material = unavailable_material.duplicate()
	transp_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	transp_material.albedo_color.a = sosbutton_shield_transparency
	sosbutton_shield.set_surface_override_material(0,transp_material)
	lable_available.visible = false
	lable_unavailable.visible = true
	
