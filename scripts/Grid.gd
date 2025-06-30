extends Node2D

export(PackedScene) var tile_class
const TILE_SIZE = 157
var shapes_resources = {} #resource name is key and actual resource is value
var reverse_shapes_resources = {} #actual resource is key and resource name is value
var star_class = preload("res://scenes/Star.tscn")
var tiles = {} #tile calss is key and grid_position is value
var reverse_tiles = {} #grid_position is key and tile class is value
var first_tile
var target_tile
var are_swapping = false
var mode


func _ready():
	mode = ResourceLoader.load("res://modes/" + 
							SavedData.data.mode + ".tres")
	scale = mode.grid_scale
	init_shapes_resources()
	# add source and destination
	add_star(0, 0)
	add_star(mode.cols - 1, mode.rows - 1)


func _input(event):
	if event is InputEventScreenTouch and event.pressed and not are_swapping:
		if touched_tile_position(event.position):
			first_tile = touched_tile_position(event.position)
	if event is InputEventScreenTouch and not event.pressed and not are_swapping:
		if touched_tile_position(event.position) and first_tile:
			target_tile = touched_tile_position(event.position)
	#swap tiles
	if first_tile and target_tile:
		if _can_be_swapped(first_tile, target_tile):
			SoundPlayer.play_sound(SoundPlayer.SWIPE)
			reverse_tiles[first_tile].swap(reverse_tiles[target_tile])
			#update tiles
			var tile1_node = reverse_tiles[first_tile]
			var tile2_node = reverse_tiles[target_tile]
			tiles[tile1_node] = target_tile
			tiles[tile2_node] = first_tile
			reverse_tiles[first_tile] = tile2_node
			reverse_tiles[target_tile] = tile1_node
		first_tile = null
		target_tile = null


func touched_tile_position(touched_point):
	for tile in tiles.keys():
		if tile.bounding_rect.has_point(touched_point):
			return tiles[tile]


func _can_be_swapped(tile1, tile2):
	var conditions = [false, false]
	#check neighbors
	var tile1Neighbors = [Vector2(tile1.x - 1, tile1.y), Vector2(tile1.x + 1, tile1.y),
							Vector2(tile1.x, tile1.y - 1), Vector2(tile1.x, tile1.y + 1)]
	if tile1Neighbors.has(tile2):
		conditions[0] = true
	#check shapes and colors
	var components1 = reverse_shapes_resources[reverse_tiles[tile1].tile_resource].rsplit("_")
	var components2 = reverse_shapes_resources[reverse_tiles[tile2].tile_resource].rsplit("_")
	for compo1 in components1:
		for compo2 in components2:
			if compo1 == compo2:
				conditions[1] = true
				break
	#final checking
	if conditions.has(false):
		return false
	else:
		return true


func init_shapes_resources():
	var dir_path = "res://shapes/"
	var dir = Directory.new()
	if dir.open(dir_path) == OK:
		dir.list_dir_begin()
		var resource_name = dir.get_next()
		while resource_name != "":
			var resource_path = dir_path + resource_name
			if ResourceLoader.exists(resource_path):
				var resource = ResourceLoader.load(resource_path)
				shapes_resources[resource_name.rsplit('.')[0]] = resource
				reverse_shapes_resources[resource] = resource_name.rsplit('.')[0]
			resource_name = dir.get_next()


func add_tile(i, j, resource_name):
	var tile = tile_class.instance()
	tile.scale_factor = mode.grid_scale.x
	tile.position.x = TILE_SIZE/2 + position.x + (j * TILE_SIZE)
	tile.position.y = TILE_SIZE/2 + position.y + (i * TILE_SIZE)
	tile.set_resource(shapes_resources[resource_name])
	tile.connect("swapping_started", self, "_swapping_started")
	tile.connect("swapping_completed", self, "_swapping_completed")
	tiles[tile] = Vector2(i, j)
	reverse_tiles[Vector2(i, j)] = tile
	add_child(tile)
	return tile


func _swapping_started():
	are_swapping = true


func _swapping_completed():
	are_swapping = false


func add_star(i, j):
	var star = star_class.instance()
	star.position.x = TILE_SIZE/2 + position.x + (j * TILE_SIZE)
	star.position.y = TILE_SIZE/2 + position.y + (i * TILE_SIZE)
	add_child(star)
