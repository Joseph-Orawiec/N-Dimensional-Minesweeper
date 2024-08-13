extends Node2D
## manages the mine field of the game

var margin = 2
const Cell: PackedScene = preload("res://scenes/cell/cell.tscn")

var open: int = 0 # cells opened
var mines: int = 10 # mine count
var field_dict: Dictionary = {} # game board
var node_dict: Dictionary = {} # node arr (parallel dictionary)

var dimension: Array[int] # size of the mine field

var adjacency_vector_dictionary: Dictionary = {} #holds arrays of adjacency vectors which are useful to loop through for a lot of things


# Called when the node enters the scene tree for the first time.
func _ready():
	
	new_game([2, 2, 2, 2, 2, 2, 2, 2, 2, 2], 10)
	
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
	
func new_game(dimensions: Array[int], mines: int):
	generate_adjacency_vectors(len(dimensions))
	
	var main_grid_container = GridContainer.new()
	add_child(main_grid_container) # on 1st dimension construction the .reparent wont work as it doesn't have a parent
	main_grid_container.size = Vector2.ONE * 50
	main_grid_container.size_flags_horizontal = GridContainer.SIZE_EXPAND_FILL
	main_grid_container.size_flags_vertical = GridContainer.SIZE_EXPAND_FILL
	
	#main_grid_container.add_theme_constant_override('h_separation', 0)
	#main_grid_container.add_theme_constant_override('v_separation', 0)
	#main_grid_container.columns = dimension[0]
	#main_grid_container.size = Vector2(dimension[0], dimension[1]) * 50
	#main_grid_container.size_flags_horizontal = GridContainer.SIZE_EXPAND_FILL
	#main_grid_container.size_flags_vertical = GridContainer.SIZE_EXPAND_FILL
	
	# TODO, connect signals 
	var node_0 = Cell.instantiate() #node naught
	var id: Array[int] = []
	id.resize(len(dimensions))
	id.fill(0)
	node_0.pid = id.duplicate()
	main_grid_container.add_child(node_0)
	
	for dimension in range(1, len(dimensions) + 1): #dimension being current dimension worked on
		var dimension_index: int = dimension - 1
		var d: int = dimensions[dimension_index] # dimension size
		
		var new_grid_container = GridContainer.new()
		new_grid_container.size_flags_horizontal = GridContainer.SIZE_EXPAND_FILL
		new_grid_container.size_flags_vertical = GridContainer.SIZE_EXPAND_FILL
		main_grid_container.reparent(new_grid_container) # 2ond Dimension+ node will already have a parent
		if (dimension % 2 == 1):
			new_grid_container.columns = d
			# only start to add margins on the 3'rd and up dimension, then progressively get bigger
			new_grid_container.add_theme_constant_override('h_separation', ((dimension - 1) / 2) * margin)
			
			# to calculate size, just multiply the old container's size by how many times it'll be copied, and add the margins of current container
			# this will factor in the margins being duplicated as well, compared to previous solution
			new_grid_container.size = main_grid_container.size * Vector2(d, 1) + Vector2(((dimension - 1) / 2) * margin, 0)
		else:
			new_grid_container.add_theme_constant_override('v_separation', ((dimension_index) / 2) * margin)
			
			new_grid_container.size = main_grid_container.size * Vector2(1, d) + Vector2(0, ((dimension_index) / 2) * margin)
		
		# It's always the case the first cell/row/3d layer/ ... / is always done
		# so we only need to duplicate it dimension size - 1 times to achieve dimension size
		
		for i in range(1, d):
			print(dimension, ' ', float(i)/d)
			var duped_gc = main_grid_container.duplicate()
			# change all of the inner cell's id's to reflect a different position
			var unvisited = duped_gc.get_children()
			while len(unvisited) != 0:
				var current = unvisited.pop_front()
				if current is ColorRect:
					# because .duplicate doesn't hold instance fields, i need to keep track of how many cells have been visited
					# versus just doing current.pid[dimension_index] = i 
					var index: int = 0
					id[index] += 1
					
					# check if on new row/layer/etc, very similar to the adj_vector generating function
					while id[index] == dimensions[index]:
						id[index] = 0
						index += 1
						id[index] += 1
					
					current.pid = id.duplicate()
				else:
					unvisited.append_array(current.get_children())
				
			
			new_grid_container.add_child(duped_gc)
		
		
		main_grid_container = new_grid_container
		add_child(main_grid_container)

# handles the logic of generating adjacency vectors for any dimension
func generate_adjacency_vectors(dimension: int):
	# don't compute if previously generated
	if adjacency_vector_dictionary.get(dimension, null) != null:
		return
	
	var adjacency_vectors: Array[Array] = []
	
	# Setup binary counter
	var arr: Array[int] = []
	arr.resize(dimension)
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
			
			# set value back to "0" and increase the next
			arr[index] = -1
			arr[index + 1] += 1
			
			# move onto checking the next bit to the right
			index += 1 #finally, increase
			
	# Remove the [0, 0, ... 0] case as that's just itself and happens to always be in the middle of the rray
	adjacency_vectors.remove_at(len(adjacency_vectors)/2) 
	
	adjacency_vector_dictionary[dimension] = adjacency_vectors

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
