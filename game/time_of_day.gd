extends Node

onready var tint_cont = $"../color_tint_container"
onready var shadow_cont = $"../color_tint_container/viewport/shadow_casters_container"

var start_time = 0.0
remotesync var progress = 0.0

const START_PROGRESS = 0.0 #0.3
const DAY_LENGTH_MSECS = 1000 * 60
const MAX_SHADOW_X_OFFSET = 16.0
const MAX_SHADOW_Y_OFFSET = 4.0
const MAX_SHADOW_ALPHA = 2.5
const NIGHT_COLOR = Color.slateblue

var day = 1.0
var night = 1.0 - day

func _ready():
	start_time = OS.get_ticks_msec()
	$day.volume_db = -999.0
	$night.volume_db = -999.0

func _process(delta):
	if is_network_master():
		var current_time = OS.get_ticks_msec() - start_time
		var new_progress = fmod(START_PROGRESS + (current_time % DAY_LENGTH_MSECS) / float(DAY_LENGTH_MSECS), 1.0)
		rset_unreliable("progress", new_progress)
		
	set_time_of_day()
	
func set_time_of_day():	
	var shadow_x_offset = -MAX_SHADOW_X_OFFSET * (progress - 0.5) * 2.0
	shadow_cont.material.set_shader_param("offset", Vector2(shadow_x_offset, -MAX_SHADOW_Y_OFFSET))
	
	#var night = abs(2.0 * (progress - 0.5))
	#var day = 1.0 - night
	
	day = clamp(abs(4 * 2.0 * abs(progress - 1.0) - 2.0) - 1.0, 0.0, 1.0)
	night = 1.0 - day
	
	var shadow_alpha = MAX_SHADOW_ALPHA * (day)
	shadow_cont.material.set_shader_param("shadowAlpha", shadow_alpha)
	
	tint_cont.material.set_shader_param("tint_color", Color.white * (1.0 - night) + NIGHT_COLOR * night)
	
	$day.volume_db = -36.0 * night
	$night.volume_db = -24.0 * day
	
