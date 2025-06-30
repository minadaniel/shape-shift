extends CanvasLayer

onready var anim = $AnimationPlayer
var next_scene
signal fade_in_finished


func _ready():
	anim.play("fade_in")


func _animation_finished(anim_name):
	if anim_name == "fade_in":
		emit_signal("fade_in_finished")
	
	if anim_name == 'fade_out':
		queue_free()
