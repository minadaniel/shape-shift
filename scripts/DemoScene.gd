extends Node

onready var tween = $Tween
onready var anim = $AnimationPlayer
onready var swipe_layer = $SwipeLayer
onready var solution_layer = $SolutionLayer
var screen_width = 720
var puzzleScenePath = "res://scenes/Puzzle.tscn"


func _on_NextButton_pressed():
	SoundPlayer.play_sound(SoundPlayer.TAP)
	tween.interpolate_property(swipe_layer, 'offset:x', 0,
		 -screen_width, 1.5, Tween.TRANS_BACK, Tween.EASE_IN_OUT)
	tween.interpolate_property(solution_layer, 'offset:x', screen_width,
		 0, 1.5, Tween.TRANS_BACK, Tween.EASE_IN_OUT)
	tween.start()


func _on_PlayButton_pressed():
	SoundPlayer.play_sound(SoundPlayer.TAP)
	SavedData.set('play_demo', false)
	Loader.load_scene(self, puzzleScenePath)
