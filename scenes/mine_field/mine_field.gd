extends Node2D
## manages the mine field of the game


const Cell: PackedScene = preload("res://scenes/cell/cell.tscn")

# variables dealing with the field
var cells_opened: int = 0
var mines: int
var bomb_list: Array[Array] # game board
var node_dict: Dictionary = {} # node arr (parallel dictionary)
var game_dimensions: Array[int] # size of the mine field
var d: int # the overall dimension of the board
var game_grid_container = GridContainer.new()

var margin = 2

var adjacency_vector_dictionary: Dictionary = {} #holds arrays of adjacency vectors which are useful to loop through for a lot of things


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	

#region Game Logic (starting and ending)
func new_game(dimensions: Array[int], m: int):
	# setup or reset variables
	game_dimensions = dimensions
	d = len(game_dimensions)
	mines = m
	cells_opened = 0
	game_grid_container.queue_free()
	generate_adjacency_vectors(d)
	
	# generate base container and node
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
	
	var id: Array[int] = []
	id.resize(d)
	id.fill(0)
	
	var node_0 = Cell.instantiate() #node naught
	node_0.pid = id.duplicate()
	node_dict[node_0.pid] = node_0
	connect_node_signals(node_0)
	main_grid_container.add_child(node_0)
	
	# expand into higher dimensions
	for dimension in range(1, d + 1): #dimension being current dimension worked on
		var dimension_index: int = dimension - 1
		var d: int = dimensions[dimension_index] # dimension size
		
		# setup new grid container to hold other GCs
		var new_grid_container = GridContainer.new()
		new_grid_container.size_flags_horizontal = GridContainer.SIZE_EXPAND_FILL
		new_grid_container.size_flags_vertical = GridContainer.SIZE_EXPAND_FILL
		main_grid_container.reparent(new_grid_container) # 2ond Dimension+ node will already have a parent
		if (dimension % 2 == 1):
			new_grid_container.columns = d
			# only start to add margins on the 3'rd and up dimension, then progressively get bigger
			new_grid_container.add_theme_constant_override('h_separation', ((dimension - 1) / 2) * margin)
			
			# to calculate size, just multiply the old container's size by how many times it'll be copied, and add the margins of current container
			# multiplied by 1 minus the dimension size (like a fencepost)
			new_grid_container.size = main_grid_container.size * Vector2(d, 1) + Vector2(((dimension - 1) / 2) * margin, 0) * (d - 1)
		else:
			new_grid_container.add_theme_constant_override('v_separation', ((dimension_index) / 2) * margin)
			new_grid_container.size = main_grid_container.size * Vector2(1, d) + Vector2(0, ((dimension_index) / 2) * margin) * (d - 1)
			
		
		# It's always the case the first cell/row/3d layer/ ... / is always done
		# so we only need to duplicate it dimension size - 1 times to achieve dimension size
		for i in range(1, d):
			print(dimension, ' ', float(i)/d)
			var duped_gc = main_grid_container.duplicate()
			# change all of the inner cell's id's to reflect a different position
			var unvisited = duped_gc.get_children()
			
			#keep searching within nested containers to find the cell
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
					node_dict[current.pid] = current
					connect_node_signals(current)
				else:
					unvisited.append_array(current.get_children())
			new_grid_container.add_child(duped_gc)
		main_grid_container = new_grid_container
		add_child(main_grid_container)
		game_grid_container = main_grid_container

func lost():
	#$gui.end_game(false)
	for i in node_dict:
		node_dict[i].lost()

# Win condition
func win():
	#$gui.end_game(true)
	for i in node_dict:
		node_dict[i].won()
#endregion


#region Cell signal functions
func _on_initialize(v):
	var bombs = mines	
	print(v)

	while bombs > 0:
		var k: Array[int] = node_dict.keys().pick_random()
		
		while (k == v or k in bomb_list): # repeat if placing on clicked cell OR another mine
			k = node_dict.keys().pick_random()
			
		# decrease mines left to place, update the field
		bombs -= 1
		bomb_list.append(k)
		node_dict[k].is_bomb = true
		
		# increment all adj cells
		for u in adjacency_vector_dictionary[d]:
			# Current cell vector w = keyCell + adjacency vector
			var w = node_dict.get(add(k, u), null)
			if (w != null):
				node_dict[add(k, u)].id += 1
				node_dict[add(k, u)].fid += 1
	print(bomb_list)
	
	# give the update to al other cells
	for i in node_dict:
		node_dict[i].has_started = true

func _on_zero_chain(v0: Array[int]):
	var nodes_checked: Array[Array] = [v0] # keep track of opened nodes using their vector key
	var node_border: Array[Array] = [v0] # keep track of what nodes are at the border in order to expand on
	var is_processing: bool = true # true to first enter the loop 
	
	while is_processing:
		var new_border = [] # generate the new node border
		for v in node_border:
			for u in adjacency_vector_dictionary[d]:
				var current_node: Array[int] = add(v, u)
				# only add if it's not on the list
				if not (current_node in new_border or current_node in nodes_checked):
					new_border.append(current_node)
		
		# continue searching?
		is_processing = false # assume false
		
		# replace node_border with only 0 cells (to later expand on)
		var culled_new_border: Array[Array] = []
		for v in new_border:
			if node_dict.get(v, null) != null: # only check if the node exists first
				nodes_checked.append(v)
				if node_dict[v].id == 0: # if atleast one cell is 0
					is_processing = true
					# add to the culled list, erasing from other array would require to loop by index and subtract 1 for every removal (as to not skip)
					culled_new_border.append(v) # numbers (and mines) will stop the opening
					
				# reveal cell if it's not a mine
				if node_dict[v].is_bomb == false:
					node_dict[v].click(false)
		
		# replace node_border variable (and no more stack overflows)
		node_border = culled_new_border

# regular click, used for determining win condition
func _on_cell_clicked(pid):
	if (node_dict[pid].is_bomb):
		lost()
	else:
		cells_opened += 1
		
	if (cells_opened == node_dict.size() - mines):
		win()

func _on_cell_flagged(v :Array[int], flagged: bool):
	for u in adjacency_vector_dictionary[d]:
		var current_node: Array[int] = add(v, u)
		if node_dict.get(current_node, null) != null:
			if flagged:
				node_dict[current_node].fid += 1 
			else:
				node_dict[current_node].fid -= 1 
	
# Change sprites of adjacent cells
func _on_chord_pressed(v):
	for u in adjacency_vector_dictionary[d]:
		var current_node = node_dict.get(add(v, u), null)
		
		if current_node != null: # if adjacent cell exists, change sprite
			current_node.chord_press()
			
# Execute chord logic
func _on_chord_released(v):
	# first we need to make sure the amount of flags = cell number
	var sum_of_flags = 0
	for u in adjacency_vector_dictionary[d]:
		var current_node = node_dict.get(add(v, u), null)
		if current_node != null: # if exists
			if current_node.is_flagged:
				sum_of_flags += 1
				
	# if so, reveal every adjacent cell
	if node_dict[v].id == sum_of_flags:
		for u in adjacency_vector_dictionary[d]:
			var current_node = node_dict.get(add(v, u), null)
			if current_node != null: # if exists
				current_node.chord_release(true)
	else: # don't actually do anything instead
		for u in adjacency_vector_dictionary[d]:
			var current_node = node_dict.get(add(v, u), null)
			if current_node != null: # if exists
				current_node.chord_release(false)
			
# reset the sprites of adjacent cell if mouse moved off
func _on_chord_canceled(v):
	for u in adjacency_vector_dictionary[d]:
		var current_node = node_dict.get(add(v, u), null)
		if current_node != null: # if exists
			current_node.chord_cancel()

func _on_toggle_highlighted(v):
	for u in adjacency_vector_dictionary[d]:
		var current_node = node_dict.get(add(v, u), null)
		
		if current_node != null: # if exists, switch_highlight
			current_node.toggle_highlight()

#region Helper functions
# a helper function to jam all the .connects into so it's in one place
func connect_node_signals(n):
	n.initialize.connect(_on_initialize)
	n.zero_chain.connect(_on_zero_chain)
	n.chord_pressed.connect(_on_chord_pressed)
	n.chord_released.connect(_on_chord_released)
	n.chord_canceled.connect(_on_chord_canceled)
	n.flagged.connect(_on_cell_flagged)
	n.clicked.connect(_on_cell_clicked)
	n.toggle_highlighted.connect(_on_toggle_highlighted)

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
			
	# Remove the [0, 0, ... 0] case as that's just itself and happens to always be in the middle of the array
	adjacency_vectors.remove_at(len(adjacency_vectors)/2) 
	
	adjacency_vector_dictionary[dimension] = adjacency_vectors

# I could have made an N-dimensional vector class but this is the only method i really need
func add(v: Array[int], u) -> Array[int]:
	# only accept numbers and other vectors
	assert((u is Array) or (u is int) or (u is float))
	
	var arr: Array[int] = []
	match typeof(u):
		TYPE_FLOAT, TYPE_INT:
			pass
			# do i even use this??
			#for i in range(len(v)):
				#arr.append(v[i] + u)
			
		TYPE_ARRAY:
			assert(len(v) == len(u))
			
			for i in range(len(v)):
				arr.append(v[i] + u[i])
			
	return arr as Array[int]
#endregion

func _input(event):
	if event.is_action_pressed("m1"):
		print("minefield ", event.position, " ", get_local_mouse_position())
