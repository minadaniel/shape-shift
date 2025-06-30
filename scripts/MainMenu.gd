extends Control

onready var mode_picker = get_node("%ModePicker")
onready var modes = get_node("%ModesContainer").get_children()
onready var sound_picker = get_node("%SoundPicker")
onready var sounds = get_node("%SoundsContainer").get_children()
var puzzleScenePath = "res://scenes/Puzzle.tscn"


func _ready():
	for mode in modes:
		if mode.name.to_lower() == SavedData.data.mode:
			translate_mode_picker(mode.rect_global_position)
			break
	
	for sound in sounds:
		if sound.name.to_lower() == str(SavedData.data.sounds).to_lower():
			translate_sound_picker(sound.rect_global_position)
			break
			
	set_sounds()


func set_sounds():
	if SavedData.data.sounds:
		AudioServer.set_bus_mute(1, false)
	else:
		AudioServer.set_bus_mute(1, true)


func translate_mode_picker(position : Vector2):
	mode_picker.rect_global_position = position
	mode_picker.rect_position -= Vector2(15, 12)


func translate_sound_picker(position : Vector2):
	sound_picker.rect_global_position = position
	sound_picker.rect_position -= Vector2(15, 12)


func _on_Play_pressed():
	SoundPlayer.play_sound(SoundPlayer.TAP)
	if SavedData.data.play_demo:
		get_tree().change_scene("res://scenes/DemoScene.tscn")
	else:
		Loader.load_scene(self, puzzleScenePath)


func _on_Help_pressed():
	SoundPlayer.play_sound(SoundPlayer.TAP)
	get_tree().change_scene("res://scenes/HelpScreen.tscn")


func _on_Easy_mode_pressed():
	SoundPlayer.play_sound(SoundPlayer.MODE_CHANGED)
	SavedData.set('mode', 'easy')
	translate_mode_picker(get_node("%Easy").rect_global_position)


func _on_Medium_mode_pressed():
	SoundPlayer.play_sound(SoundPlayer.MODE_CHANGED)
	SavedData.set('mode', 'medium')
	translate_mode_picker(get_node("%Medium").rect_global_position)


func _on_Hard_mode_pressed():
	SoundPlayer.play_sound(SoundPlayer.MODE_CHANGED)
	SavedData.set('mode', 'hard')
	translate_mode_picker(get_node("%Hard").rect_global_position)


func _on_Sfx_ON_pressed():
	SavedData.set('sounds', true)
	AudioServer.set_bus_mute(1, false)
	translate_sound_picker(get_node("%True").rect_global_position)


func _on_Sfx_OFF_pressed():
	SavedData.set('sounds', false)
	AudioServer.set_bus_mute(1, true)
	translate_sound_picker(get_node("%False").rect_global_position)


func _on_QuitButton_pressed():
	get_tree().quit()
