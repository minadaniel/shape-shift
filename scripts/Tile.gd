extends Node2D

onready var shape = $Shape
onready var glowing = $Glowing
onready var box = $Box
var tile_resource setget set_resource
const SIZE = 157
var bounding_rect
onready var tween = $Tween
signal swapping_started
signal swapping_completed
var is_glowing = false
signal glowing_started
var scale_factor


func _ready():
	shape.texture = tile_resource.get_texture()
	shape.modulate = tile_resource.color
	glowing.texture = tile_resource.get_texture()
	glowing.modulate = tile_resource.color
	bounding_rect = Rect2(global_position.x - (SIZE/2 * scale_factor), 
							global_position.y - (SIZE/2 * scale_factor), 
							SIZE * scale_factor, SIZE * scale_factor)
	#flip randomly
	box.scale = Vector2(pow(-1, randi() % 2), pow(-1, randi() % 2))


func set_resource(resource):
	tile_resource = resource


func swap(target_tile):
	var initial_position = global_position
	tween.interpolate_property(self, 'global_position', initial_position, 
			target_tile.global_position, 0.6, Tween.TRANS_BACK, Tween.EASE_OUT)
	tween.interpolate_property(target_tile, 'global_position', 
			target_tile.global_position, initial_position, 0.6, 
			Tween.TRANS_BACK, Tween.EASE_OUT)
	#update bounding rects
	bounding_rect = Rect2(target_tile.global_position.x - (SIZE/2 * scale_factor), 
						target_tile.global_position.y - (SIZE/2 * scale_factor), 
						SIZE * scale_factor, SIZE * scale_factor)
	target_tile.bounding_rect = Rect2(initial_position.x - (SIZE/2 * scale_factor), 
							initial_position.y - (SIZE/2 * scale_factor), 
							SIZE * scale_factor, SIZE * scale_factor)
	tween.start()


func _on_Tween_tween_started(_object, _key):
	emit_signal("swapping_started")


func _on_Tween_tween_completed(_object, _key):
	emit_signal("swapping_completed")


func glow():
	if not is_glowing:
		$AnimationPlayer.play("glow")


func _on_AnimationPlayer_animation_started(anim_name):
	if anim_name == 'glow':
		is_glowing = true
		emit_signal("glowing_started")
