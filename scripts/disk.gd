extends Node3D

var minv = 5.0
var maxv = 10.0

func _process(delta: float) -> void:
	for s : Node3D in get_children():
		s.rotation_degrees.y += delta * 3.0
		s.get_child(0).rotation_degrees.x += delta * randf_range(minv,maxv)
		s.get_child(0).rotation_degrees.y += delta * randf_range(minv,maxv) 
		s.get_child(0).rotation_degrees.z += delta * randf_range(minv,maxv)
		
