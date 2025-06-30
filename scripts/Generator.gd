extends Node

var puzzle = {}
var mode = ResourceLoader.load("res://modes/" 
			+ SavedData.data.mode + ".tres")
var rows = mode.rows
var cols = mode.cols
var colors = ['red', 'green', 'blue']
var shapes = ['rect', 'circle', 'triangle']
var standard = mode.standard
var swaps = mode.swaps
var solved_puzzle = {
	Vector2(0, 1): "red_triangle",
	Vector2(0, 2): "blue_triangle",
	Vector2(0, 3): "red_rect",
	Vector2(1, 0): "red_rect",
	Vector2(1, 1): "red_rect",
	Vector2(1, 2): "green_triangle",
	Vector2(1, 3): "red_rect",
	Vector2(2, 0): "red_rect",
	Vector2(2, 1): "red_rect",
	Vector2(2, 2): "blue_triangle",
	Vector2(2, 3): "red_triangle",
	Vector2(3, 0): "red_rect",
	Vector2(3, 1): "red_rect",
	Vector2(3, 2): "red_rect",
	Vector2(3, 3): "green_triangle",
	Vector2(4, 0): "red_rect",
	Vector2(4, 1): "red_rect",
	Vector2(4, 2): "red_rect",
}


func _ready():
	randomize()
	
	init_consistent_puzzle()
	
	while not good_puzzle():
		generate_puzzle()
	
	swap_cells()


func init_consistent_puzzle():
	for j in cols:
		for i in rows:
			puzzle[Vector2(j, i)] = 'red_rect'


func swap_cells():
	for _i in range(swaps):
		var rand_cell = puzzle.keys()[randi() % puzzle.keys().size()]
		var neighbors = _valid_neighbors(rand_cell)
		var rand_neighbor = neighbors[randi() % neighbors.size()]
		if puzzle.has(rand_neighbor):
			if _can_be_swapped(rand_cell, rand_neighbor):
				var resource1 = puzzle[rand_cell]
				var resource2 = puzzle[rand_neighbor]
				puzzle[rand_cell] = resource2
				puzzle[rand_neighbor] = resource1


func _can_be_swapped(cell1, cell2):
	var ok = false
	var components1 = puzzle[cell1].rsplit("_")
	var components2 = puzzle[cell2].rsplit("_")
	for compo1 in components1:
		for compo2 in components2:
			if compo1 == compo2:
				ok = true
				break
	return ok


func good_puzzle():
	var good = true
	var puzzle_parameters = _count_individuals()
	for key in puzzle_parameters:
		if puzzle_parameters[key] >= standard:
			good = false
			break
	return good


func _count_individuals():
	var shapes_and_colors = []
	for resource_name in puzzle.values():
		shapes_and_colors.append(resource_name)
	var individuals = {}
	for item in shapes_and_colors:
		var components = item.rsplit("_")
		if individuals.has(components[0]):
			individuals[components[0]] = individuals[components[0]] + 1
		else:
			individuals[components[0]] = 1
		if individuals.has(components[1]):
			individuals[components[1]] = individuals[components[1]] + 1
		else:
			individuals[components[1]] = 1
	return individuals


func generate_puzzle():
	puzzle.clear()
	
	var path_components = _path_components(_start_point())
	var solution_path = _astar_path()
	# assign points in solution path to one path components
	for point in solution_path:
		if not (point.y == 0 and point.x == 0 or point.x == cols - 1 and point.y == rows - 1):
			puzzle[point] = path_components[randi() % path_components.size()]
	fill_remaining()


func fill_remaining():
	var empty = []
	for j in range(cols):
		for i in range(rows):
			if not puzzle.has(Vector2(j, i)):
				if not (j == 0 and i == 0 or j == cols - 1 and i == rows - 1):
					empty.append(Vector2(j, i))
	while not empty.empty():
		empty = _assign_empty_cell(empty)


func _assign_empty_cell(empty):
	for cell in empty:
		var cellNeighbors = _valid_neighbors(cell)
		for neighbor in cellNeighbors:
			if puzzle.has(neighbor):
				var resource_name = _set_valid_neighbor(puzzle[neighbor])
				puzzle[cell] = resource_name
				empty.erase(cell)
	return empty


func _set_valid_neighbor(current : String):
	var resource_name = current
	var parameters = current.rsplit('_')
	while resource_name == current:
		var chosen = parameters[randi() % parameters.size()]
		if colors.has(chosen):
			resource_name = chosen + "_" + shapes[randi() % shapes.size() - 1]
		else:
			resource_name = colors[randi() % colors.size() - 1] + "_" + chosen
	return resource_name


func _astar_path():
	#add points to astar
	var astar = AStar2D.new()
	var index = 0
	for j in range(cols):
		for i in range(rows):
			var weight = randf()
			astar.add_point(index, Vector2(j, i), weight)
			index += 1
	#connect points in astar
	for i in range(astar.get_points().size()):
		var neighbors = _valid_neighbors(astar.get_point_position(i))
		var point_id = astar.get_points()[i]
		for neighbor in neighbors:
			var neighbor_id = get_point_id_in_astar(astar, neighbor)
			astar.connect_points(point_id, neighbor_id, false)
	#return path points
	var start = 0
	var end = (rows * cols) - 1
	return astar.get_point_path(start, end)


func get_point_id_in_astar(astar: AStar2D, position: Vector2):
	var id = 0
	for i in range(astar.get_points().size()):
		var curr = astar.get_point_position(i)
		if curr == position:
			id = i
	return id


func _valid_neighbors(point : Vector2):
	# Consider all four directions
	var neighbors = [Vector2(point.x-1, point.y), Vector2(point.x+1, point.y), 
				 Vector2(point.x, point.y-1), Vector2(point.x, point.y+1)]
	# Filter out neighbors that are out of bounds
	var valid = []
	for n in neighbors:
		if n.x >= 0 and n.x < cols and n.y >= 0 and n.y < rows:
			valid.append(n)
	return valid


func _path_components(point):
	var path = []
	if colors.has(point):
		for shape in shapes:
			path.append(point + "_" + shape)
	else:
		for color in colors:
			path.append(color + "_" + point)
	return path


func _start_point():
	var all_options = []
	for i in range(colors.size()):
		all_options.append(colors[i])
	for j in range(shapes.size()):
		all_options.append(shapes[j])
	var point = all_options[randi() % all_options.size() - 1]
	return point
