extends Node

var path = "user://data.json"
var data
var file = File.new()


func _ready():
	if file.file_exists(path):
		file.open(path, File.READ)
		data = parse_json(file.get_as_text())
	else:
		file.open(path, File.WRITE)
		data = {'mode': 'easy', 'sounds': true, 'play_demo': true}
		file.store_string(to_json(data))
	file.close()


func set(what, value):
	file.open(path, File.WRITE)
	data[what] = value
	file.store_string(to_json(data))
	file.close()
