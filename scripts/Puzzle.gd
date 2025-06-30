extends Node

export(PackedScene) var generatorClass
var generator
var puzzle
onready var grid = $Grid
var rows
var cols
var end_point
var solution_path = []
export(PackedScene) var victoryEffectClass
const ATTEMPTS_T0_ANOTHER_PUZZLE = 10
var rand_tile_when_solved


func _ready():
	_init_puzzle_generator()
#	_init_solved_puzzle()
	end_point = Vector2(cols - 1, rows - 1)
	
	# if solved generate another puzzle
	for _i in range(ATTEMPTS_T0_ANOTHER_PUZZLE):
		if is_solved():
			grid.tiles.clear()
			grid.reverse_tiles.clear()
			generator.queue_free()
			_init_puzzle_generator()
		else:
			break
	
	SoundPlayer.play_sound(SoundPlayer.PUZZLE_STARTED)
	
	#start animation
	$Tween.interpolate_property($DarkRect, 'color:a', 1, 0, 2.5, 
		Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$Tween.start()
	yield($Tween, "tween_completed")
	$DarkRect.visible = false


func _init_puzzle_generator():
	generator = generatorClass.instance()
	puzzle = generator.puzzle
	rows = generator.rows
	cols = generator.cols
	add_child(generator)
	_init_tiles()


# for test purposes
func _init_solved_puzzle():
	generator = generatorClass.instance()
	puzzle = generator.puzzle
	rows = generator.rows
	cols = generator.cols
	add_child(generator)
	for key in generator.solved_puzzle:
		var tmp_tile = grid.add_tile(key.x, key.y, generator.solved_puzzle[key])
		tmp_tile.connect("glowing_started", self, "_init_victory_effect")


func _init_victory_effect():
	var victoryEffect = victoryEffectClass.instance()
	get_tree().root.call_deferred('add_child', victoryEffect)
	victoryEffect.connect("finished", self, "_remove")


func _remove():
	queue_free()


func _init_tiles():
	for key in puzzle.keys():
		var i = key.x
		var j = key.y
		var resource_name = puzzle[key]
		grid.add_tile(i, j, resource_name)


func _process(_delta):
	if is_solved() and grid.is_processing_input():
		rand_tile_when_solved = grid.reverse_tiles[solution_path[0]]
		rand_tile_when_solved.connect("glowing_started", self, "_init_victory_effect")
		for point in solution_path:
			grid.reverse_tiles[point].glow()
		SoundPlayer.play_sound(SoundPlayer.PUZZLE_SOLVED)
		grid.set_process_input(false)


func valid_path(start, end):
	var start_components = grid.reverse_shapes_resources[grid.reverse_tiles[start].tile_resource].rsplit("_")
	var end_components = grid.reverse_shapes_resources[grid.reverse_tiles[end].tile_resource].rsplit("_")
	var matches = []
	for compo1 in start_components:
		for compo2 in end_components:
			if compo1 == compo2:
				if not matches.has(compo1):
					matches.append(compo1)
	if not matches.empty():
		for item in matches:
			var all_matches = find_all_matches(item)
			var astar = create_astar(all_matches)
			var path = astar.get_point_path(generator.get_point_id_in_astar(astar, start), 
				generator.get_point_id_in_astar(astar, end))
			if path.size() > 1:
				for point in path:
					solution_path.append(point)
				return true
	return false


func find_all_matches(cell):
	var all_matches = []
	for grid_pos in grid.reverse_tiles:
		var rsc_name = grid.reverse_shapes_resources[grid.reverse_tiles[grid_pos].tile_resource]
		if rsc_name.begins_with(cell) or rsc_name.ends_with(cell):
			all_matches.append(grid_pos)
	return all_matches


func create_astar(cells):
	var astar = AStar2D.new()
	var index = 0
	for cell in cells:
		astar.add_point(index, cell)
		index += 1
	#connect points whenever possible
	for i in range(astar.get_points().size()):
		var point = astar.get_point_position(i)
		var point_id = astar.get_points()[i]
		var point_neighbors = [Vector2(point.x - 1, point.y), Vector2(point.x + 1, point.y),
							Vector2(point.x, point.y - 1), Vector2(point.x, point.y + 1)]
		for neighbor in point_neighbors:
			if cells.has(neighbor):
				var neighbor_id = generator.get_point_id_in_astar(astar, neighbor)
				astar.connect_points(point_id, neighbor_id, false)
	return astar


func is_solved():
	if (valid_path(Vector2(0, 1), Vector2(end_point.x - 1, end_point.y))
		or valid_path(Vector2(0, 1), Vector2(end_point.x, end_point.y - 1))
		or valid_path(Vector2(1, 0), Vector2(end_point.x - 1, end_point.y))
		or valid_path(Vector2(1, 0), Vector2(end_point.x, end_point.y - 1))):
		return true
	else:
		return false


func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST:
		SoundPlayer.play_sound(SoundPlayer.BACK)
		get_tree().change_scene("res://scenes/MainMenu.tscn")
