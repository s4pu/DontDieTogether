extends Node

onready var tint_cont = $"../color_tint_container"
onready var shadow_cont = $"../color_tint_container/viewport/shadow_casters_container"

var start_time = 0.0

const DAY_LENGTH_MSECS = 1000 * 60 * 2
const MAX_SHADOW_X_OFFSET = 16.0
const MAX_SHADOW_Y_OFFSET = 4.0
const MAX_SHADOW_ALPHA = 2.5
const NIGHT_COLOR = Color.darkslateblue

func _ready():
	start_time = OS.get_ticks_msec()

func _process(delta):
	
	var current_time = OS.get_ticks_msec() - start_time
	var progress = (current_time % DAY_LENGTH_MSECS) / float(DAY_LENGTH_MSECS)
	set_time_of_day(progress)
	
func set_time_of_day(progress : float):
	progress = fmod(progress, 1.0)
	
	var shadow_x_offset = -MAX_SHADOW_X_OFFSET * (progress - 0.5) * 2.0
	shadow_cont.material.set_shader_param("offset", Vector2(shadow_x_offset, -MAX_SHADOW_Y_OFFSET))
	
	var night = abs(2.0 * (progress - 0.5))
	
	var shadow_alpha = MAX_SHADOW_ALPHA * (1.0 - night)
	shadow_cont.material.set_shader_param("shadowAlpha", shadow_alpha)
	
	
	tint_cont.material.set_shader_param("tint_color", Color.white * (1.0 - night) + NIGHT_COLOR * night)
	
