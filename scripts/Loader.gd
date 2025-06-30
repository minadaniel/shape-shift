extends Node

onready var loadingScreenClass = preload("res://scenes/LoadingScreen.tscn")


func load_scene(current_scene, next_scene):
	var loadingScreen = loadingScreenClass.instance()
	get_tree().root.call_deferred('add_child', loadingScreen)
	var loader = ResourceLoader.load_interactive(next_scene)
	current_scene.queue_free()
	yield(get_tree().create_timer(1.5), "timeout")
	while true:
		var err = loader.poll()
		if err == ERR_FILE_EOF:
			var scene = loader.get_resource().instance()
			get_tree().root.call_deferred('add_child', scene)
			loadingScreen.queue_free()
			return
