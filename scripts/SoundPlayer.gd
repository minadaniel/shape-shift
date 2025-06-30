extends Node

onready var audioPlayers = $AudioPlayers
const TAP = preload("res://sounds/tap.wav")
const MODE_CHANGED = preload("res://sounds/mode_changed.wav")
const PUZZLE_STARTED = preload("res://sounds/puzzle_started.wav")
const BACK = preload("res://sounds/back.wav")
const SWIPE = preload("res://sounds/swipe.wav")
const PUZZLE_SOLVED = preload("res://sounds/puzzle_solved.wav")
const WOW = preload("res://sounds/wow.mp3")


func play_sound(sound):
	if AudioServer.is_bus_mute(1):
		return
	for audio in audioPlayers.get_children():
		if not audio.playing:
			audio.stream = sound
			audio.play()
			break
