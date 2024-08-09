extends Node2D
## manages the mine field of the game

var open = 0 # cells opened
var mines = 10 # mine count
var field_dict = {} # game board
var node_dict = {} # node arr (parallel dictionary)
var cell = preload("res://scenes/cell/cell.tscn")
var dimension # size of the mine field

const adjacency_vectors = [] # useful to loop through for a lot of things


# Called when the node enters the scene tree for the first time.
func _ready():

	
	new_game([10, 10], 10)
	
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
	
func new_game(dimension, mines):
	var d = len(dimension)
	var grid_container = GridContainer.new()
	
	grid_container.add_theme_constant_override('h_separation', 0)
	grid_container.add_theme_constant_override('v_separation', 0)
	grid_container.columns = dimension[0]
	grid_container.size = Vector2(dimension[0], dimension[1]) * 50
	
	for y in dimension[1]:
		for x in dimension[0]:
			var temp_id = dimension.duplicate()
			temp_id[0] = x
			temp_id[1] = y
			
			field_dict[temp_id] = 0
			node_dict[temp_id] = cell.instantiate()
			
			var current_cell = node_dict[temp_id]
			
			grid_container.add_child(current_cell)
			
	add_child(grid_container)

# I could have made an N-dimensional vector class but this is the only method i really need
func add(v, u):
	# only accept numbers and other vectors
	assert((u is Array) or (u is int) or (u is float))
	
	var arr = []
	match typeof(u):
		TYPE_FLOAT, TYPE_INT:
			for i in range(len(v)):
				arr.append(v[i] + u)
			
		TYPE_ARRAY:
			assert(len(v) == len(u.v))
			
			for i in range(len(v)):
				arr.append(v[i] + u.v[i])
			
	return arr
