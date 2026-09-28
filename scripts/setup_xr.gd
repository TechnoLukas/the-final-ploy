extends Node

signal _on_end_success

signal _on_end_fail

signal _on_game_reset

var xr_interface: XRInterface

func recenter():
	pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	xr_interface = XRServer.primary_interface	
	if xr_interface and xr_interface.is_initialized():
		print("OpenXR initialised successfully")

		# Turn off v-sync!
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

		# Change our main viewport to output to the HMD
		get_viewport().use_xr = true
		xr_interface.pose_recentered.connect(recenter)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
