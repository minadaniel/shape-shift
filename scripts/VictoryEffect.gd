extends CanvasLayer

onready var wow = $Label
signal finished

func _ready():
	get_tree().set_current_scene(self)
	
	for child in $Particles.get_children():
		child.emitting = true
	
	yield(get_tree().create_timer(1.5), "timeout")
	
	$Tween.interpolate_property($Background, 'modulate:a', 0, 1, 3, 
		Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.interpolate_property(wow, "rect_scale", Vector2(0, 0), 
		Vector2(1, 1), 4, Tween.TRANS_EXPO, Tween.EASE_IN_OUT)
	$Tween.interpolate_property(wow, "rect_rotation", 0, 360, 4.5, 
		Tween.TRANS_BOUNCE, Tween.EASE_IN_OUT)
	$Tween.start()
	
	yield(get_tree().create_timer(1.0), "timeout")
	SoundPlayer.play_sound(SoundPlayer.WOW)

	yield($Tween, "tween_all_completed")
	emit_signal("finished")
	$Again.visible = true


func _on_AgainButton_pressed():
	SoundPlayer.play_sound(SoundPlayer.TAP)
	var puzzleScenePath = "res://scenes/Puzzle.tscn"
	Loader.load_scene(self, puzzleScenePath)


func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST:
		SoundPlayer.play_sound(SoundPlayer.BACK)
		get_tree().change_scene("res://scenes/MainMenu.tscn")
