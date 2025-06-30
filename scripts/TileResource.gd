extends Resource
class_name TileResource


enum Types {RECT, TRIANGLE, CIRCLE}
export(Types) var type
var texture
export(Color) var color
var rect = preload("res://assets/rect.png")
var triangle = preload("res://assets/triangle.png")
var circle = preload("res://assets/circle.png")


func get_texture():
	match type:
		Types.RECT:
			return rect
		Types.CIRCLE:
			return circle
		Types.TRIANGLE:
			return triangle
