extends Node3D

@export var material_off : StandardMaterial3D
@export var material_on : StandardMaterial3D
var status = 0 # 1 is on, 0 is off

@onready var obj : MeshInstance3D =  $Cylinder

var timer : Timer

func _ready() -> void:
	timer = Timer.new()
	timer.wait_time = 1.0
	timer.one_shot = false 
	timer.autostart = true  
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)

func _process(delta: float) -> void:
	$TextPivot.rotation_degrees.y += 20 * delta
	
func _on_timer_timeout() -> void:
	status =! status
	if status == false: 
		obj.set_surface_override_material(0,material_off)
	else:
		obj.set_surface_override_material(0,material_on)


func _on_sosbeacon_area_entered(area: Area3D) -> void:
	if area.name == "PLAYER":
		area.owner._on_sosbeacon_area_entered()


func _on_sosbeacon_area_exited(area: Area3D) -> void:
	if area.name == "PLAYER":
		area.owner._on_sosbeacon_area_exited()
