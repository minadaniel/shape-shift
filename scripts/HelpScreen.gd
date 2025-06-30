extends Sprite

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST:
		SoundPlayer.play_sound(SoundPlayer.BACK)
		get_tree().change_scene("res://scenes/MainMenu.tscn")
