extends Button

export(Color) var color

func _ready():
	add_color_override("font_color", color)
	add_color_override("font_color_disabled", color)
	add_color_override("font_color_focus", color)
	add_color_override("font_color_hover", color)
	add_color_override("font_color_pressed", color)
