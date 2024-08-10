extends Node2D
## manages the mine field of the game

var open: int = 0 # cells opened
var mines: int = 10 # mine count
var field_dict: Dictionary = {} # game board
var node_dict: Dictionary = {} # node arr (parallel dictionary)
var cell: PackedScene = preload("res://scenes/cell/cell.tscn")
var dimension: Array[int] # size of the mine field

var adjacency_vectors = []
#var adjacency_vector_dictionary: Dictionary = {} #holds arrays of adjacency vectors which are useful to loop through for a lot of things


# Called when the node enters the scene tree for the first time.
func _ready():

	
	new_game([10, 10], 10)
	
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
	
func new_game(dimension: Array[int], mines: int):
	var d: int = len(dimension) # Nth dimension
	
	# Setup binary counter
	var arr: Array[int] = []
	arr.resize(d)
	arr.fill(-1)
	
	
	var isDone: bool = false
	# Start counting
	while !isDone:
		adjacency_vectors.append(arr.duplicate())
		arr[0] += 1
		
		# check if should rollover
		var index: int = 0 #index to check for rollover
		while arr[index] == 2: # only continue rolling over if == 2
			if index == len(arr) - 1: #if about to rollover last base 3 bit, then it's finished
				isDone = true
				break
			
			arr[index] = -1
			arr[index + 1] += 1
			
			# about to rollover last index
			
				
			index += 1 #finally, increase
	# Remove the [0, 0, ... 0] case as that's just itself and happens to always be in the middle of the rray
	adjacency_vectors.remove_at(len(adjacency_vectors)/2) 
	
	
	
	
	var grid_container = GridContainer.new()
	
	grid_container.add_theme_constant_override('h_separation', 0)
	grid_container.add_theme_constant_override('v_separation', 0)
	grid_container.columns = dimension[0]
	grid_container.size = Vector2(dimension[0], dimension[1]) * 50
	
	for y in dimension[1]:
		for x in dimension[0]:
			var temp_id: Array[int] = dimension.duplicate()
			temp_id[0] = x
			temp_id[1] = y
			
			field_dict[temp_id] = 0
			node_dict[temp_id] = cell.instantiate()
			
			var current_cell = node_dict[temp_id]
			
			grid_container.add_child(current_cell)
			
	add_child(grid_container)

# I could have made an N-dimensional vector class but this is the only method i really need
func add(v: Array[int], u):
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
