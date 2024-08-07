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
	new_game([9, 9], 10)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
	
func new_game(dimension, mines):
	var d = len(dimension)
	var grid_container = GridContainer.new()
	
	print(grid_container.theme_override_constants.h_separation)
	

	
	
	print_tree_pretty()
	
	pass
	
	
# I could have made an N-dimensional vector class but this is the only method i really need
func add(u):
	# only accept numbers and other vectors
	assert((u is Array) or (u is int) or (u is float))
	
	var arr = []
	match typeof(u):
		TYPE_FLOAT, TYPE_INT:
			for i in range(len(self.v)):
				arr.append(self.v[i] + u)
			
		TYPE_ARRAY:
			assert(len(self.v) == len(u.v))
			
			for i in range(len(self.v)):
				arr.append(self.v[i] + u.v[i])
			
	return arr
