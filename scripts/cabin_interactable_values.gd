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

@export var sos_popup_failed : Node3D
@export var sos_popup_failed_sound : AudioStreamPlayer3D
@export var sos_popup_succesfull : Node3D
@export var sos_popup_succesfull_sound : AudioStreamPlayer3D
var sos_popup_succesfull_timer : Timer
var sos_popup_failed_timer : Timer

@onready var radar_rotation = $RadarMenu/HorRad/Rotation
@onready var radar_hor_point = $RadarMenu/HorRad/Rotation/Node3D3/Point
@onready var radar_ver_point = $RadarMenu/VerRad/Rotation/Node3D3/Point2
@onready var radar_scanner = $RadarMenu/HorRad/Scanner
var radar_ping_in_timer : Timer
var radar_ping_out_timer : Timer
var is_pinged = false
var is_pingin_in = false
var is_pingin_out = false
var dynamic_radar_mat
@onready var radar_ping_sound = $Sound/RadarPingSound

func _ready() -> void:
	current_volume = randf_range(min_linear, max_linear)
	target_volume = current_volume
	#deactivate_sos_button()

	sos_popup_succesfull_timer = Timer.new()
	sos_popup_succesfull_timer.wait_time = 3.0
	sos_popup_succesfull_timer.timeout.connect(_on_popup_succesfull_timeout)
	add_child(sos_popup_succesfull_timer)
	
	sos_popup_failed_timer = Timer.new()
	sos_popup_failed_timer.wait_time = 3.0
	sos_popup_failed_timer.timeout.connect(_on_popup_failed_timeout)
	add_child(sos_popup_failed_timer)
	
	radar_ping_out_timer = Timer.new()
	radar_ping_out_timer.wait_time = 0.2
	radar_ping_out_timer.timeout.connect(_on_ping_out)
	add_child(radar_ping_out_timer)
	
	dynamic_radar_mat = radar_hor_point.mesh.surface_get_material(0).duplicate()
	dynamic_radar_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	dynamic_radar_mat.albedo_color.a = 0.0
	radar_hor_point.set_surface_override_material(0, dynamic_radar_mat)
	radar_ver_point.set_surface_override_material(0, dynamic_radar_mat)
	
	deactivate_sos_button()
	
	SetupXr._on_game_reset.connect(_on_game_reset)
	SetupXr._on_end_fail.connect(_on_end_fail)
	
	await get_tree().create_timer(1.0).timeout # Waiting the scene to actualy visualise on playerside and only then play
	engine_sound.play()
	engine_sound2.play()
	engine_sound3.play()

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
	engine_sound3.pitch_scale =  max(minf(abs(yoke_angle_value)*0.5 + abs(yokecollumn_angle_value)*0.5, 1.0), 0.001) * 0.6
	
	
	radar_scanner.rotation_degrees.z += -30 * delta
	var pos_diff = (owner.sosbeacon.global_position - owner.global_position) / 100.0
	var ver_point_pos = Vector3(0.0,pos_diff.y,0.0)
	var hor_point_pos = Vector3(pos_diff.x,-pos_diff.z,0.0)
	var rotated_hor_point_pos = hor_point_pos.rotated(Vector3(0,0,1),-owner.rotation.y)
	#var angle_diff_degrees = rad_to_deg(angle_difference(radar_scanner.rotation.z, Vector3.UP.angle_to(rotated_hor_point_pos)))
	var angle_diff_degrees = rad_to_deg(angle_difference(radar_scanner.rotation.z, Vector2.UP.angle_to(-Vector2(rotated_hor_point_pos.x, rotated_hor_point_pos.y))))

	if hor_point_pos.length() < 1.1 and abs(angle_diff_degrees) <= 2.0:
		if not is_pinged:
			_on_ping_in()
			radar_hor_point.position = rotated_hor_point_pos
			radar_ver_point.position = ver_point_pos
			is_pinged = true
	
	if is_pingin_in:
		dynamic_radar_mat.albedo_color.a = move_toward(dynamic_radar_mat.albedo_color.a, 1.0, delta * 5.0)
		
	if is_pingin_out:
		dynamic_radar_mat.albedo_color.a = move_toward(dynamic_radar_mat.albedo_color.a, 0.0, delta * 0.5)
	
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
	
func _on_sosbutton_succeeded():
	button_click_sound.playing = true
	sos_popup_succesfull_sound.playing = true
	sos_popup_succesfull_timer.start()
	sos_popup_succesfull.visible = true
	
	SetupXr._on_end_success.emit()
	await get_tree().create_timer(5.0).timeout
	SetupXr._on_game_reset.emit()
	
func _on_sosbutton_failed():
	sos_popup_failed_sound.playing = true
	sos_popup_failed_timer.start()
	sos_popup_failed.visible = true
	
func _on_popup_succesfull_timeout():
	sos_popup_succesfull.visible = false

func _on_popup_failed_timeout():
	sos_popup_failed.visible = false
	
func _on_ping_in():
	radar_ping_sound.playing = true
	is_pingin_in = true
	is_pingin_out = false
	radar_ping_out_timer.start()
	
func _on_ping_out():
	is_pingin_in = false
	is_pingin_out = true
	is_pinged = false
	$Debug/ThrottleValue.text = ""
	
func _on_game_reset():
	deactivate_sos_button()
	
func _on_end_fail():
	SetupXr._on_game_reset.emit()
