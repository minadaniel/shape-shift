extends Node2D

export(PackedScene) var fade_screen_class
export(PackedScene) var main_menu_scene_class
var fade_screen


func _on_Timer_timeout():
	fade_screen = fade_screen_class.instance()
	fade_screen.connect('fade_in_finished', self, '_fadeScreen_finished_fadeIn')
	get_tree().root.call_deferred('add_child', fade_screen)


func _fadeScreen_finished_fadeIn():
	var main_menu = main_menu_scene_class.instance()
	get_tree().root.call_deferred('add_child', main_menu)
	fade_screen.anim.play('fade_out')
	queue_free()
