extends StaticBody2D
signal select_building
signal deselect_building

var max_hp

var good_team
var hp = 50
var damage_on_contact = 0
var costs = 0
var needed_material = []

# Called when the node enters the scene tree for the first time.
func _ready():    
	set_hitpoints(max_hp)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func set_color(color):
	$Sprite.material.set_shader_param("outline_color", color)
	var box = StyleBoxFlat.new()
	box.bg_color = color
	$Health.add_stylebox_override("fg", box)
	
func destroy():
	var particles = preload("res://buildings/Dying_Particle.tscn").instance()
	particles.position = position
	particles.get_node("Particles2D").emitting = true
	get_parent().add_child(particles)
	set_hitpoints(0)
	queue_free()

remotesync func take_damage(damage):
	hp -= damage
	set_hitpoints(hp)
	$impact_sounds.play_random()
	if (hp <= 0):
		destroy()

func _on_Area2D_mouse_entered():
	emit_signal("select_building", $".")

func _on_Area2D_mouse_exited():
	emit_signal("deselect_building")
	
func set_hitpoints(num):
	var norm_hp = float(num) / max_hp
	if norm_hp == 1:
		$Health.visible = false
	else:
		$Health.visible = true
		
	$Health.value = norm_hp
