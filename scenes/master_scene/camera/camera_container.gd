extends GridContainer

var previous_coordinates: Vector2
var is_dragging: bool
const pa: float = 1.11 # Area proportionality constant
const zoom_min: float = pow(1.11, -22/2.0) #roughly .3
const zoom_max: float = pow(1.11, 21/2.0) #roughly 2.9915

var cameras #placeholder to be initialized later
var zoom1 #placeholder to be initialized later
var camera_dict = {}
var world = null
var dimensions = null
var use_multicam = false

const viewport: PackedScene = preload("res://scenes/master_scene/camera/sub_viewport_container.tscn")
@onready var main_container = viewport.instantiate()

# Called when the node enters the scene tree for the first time.
func _ready():
	add_child(main_container)
	self.resized.connect(_on_resized)
	
	# set's master_container and subviewport_original for all future subviewports via static variable
	main_container.master_container = self
	main_container.subviewport_0 = main_container
	pass
	
func _on_resized():
	get_child(0).size = size

func initialize(node, d):
	world = node
	dimensions = d
	
	
	cameras = get_tree().get_nodes_in_group("cameras")
	zoom1 = cameras[0].zoom
	world.reparent(main_container.get_child(0), true)

func multicam_on():
	#make sure not to duplicate the world
	world.reparent(self)
	
	var d: int = len(dimensions)
	
	# array of values in order of how far to shift
	# 0: 3st and 4ond | 1: 5rd and 6th | 2: 7th and 8th
	var positional_shift: Array[Array]
	
	
	# coding this inductively so i need to setup the base case and all that
	# calculate how far each camera needs to be
	var horizontal_cells = dimensions[0] * world.cell_size
	var vertical_cells = null
	var horizontal_shift = null
	var vertical_shift = null
	
	# would use try except blocks here but instead
	if d >= 2:
		vertical_cells = dimensions[1] * world.cell_size
	if d >= 3:
		horizontal_shift = horizontal_cells + world.margin
		
		positional_shift = [[horizontal_shift, 0]] # setups up base case
	if d >= 4:
		vertical_shift = vertical_cells + world.margin
		
		positional_shift[0][1] = vertical_shift # sets up base case, but vertically
	
	# i is for dimensions, but indexed at 0, so starts at the 5th dimension
	# this tackles dimensions 2 at a time and so the base case was the 3rd and 4th dimension
	for i in range(4, d, 2):
		var previous_shift = positional_shift[i/2 - 2] # previous dimensions shift
		

		var current_shift_x = previous_shift[0] * dimensions[i] + world.margin
		# how wide the previous dimension made it * how many times it'll be copies + margin 
		
		#take a 3x3x3 minesweeper board (but only examine a horizontal line)
		# [*** *** ***]
		# positional_shift[0] stores how many pixels to offset the camera to view the next layer "up/down" over
		# which stores this distance [*** ] 
		# [*** *** ***  *** *** ***  *** *** ***]
		# we now need to solve for that offset [*** *** ***  ]
		
		# repeat above but for veritcally
		var current_shift_y = 0
		if d >= i + 2: # might not exist it's dimension, remember i is 0th index dimension so it's +2
			current_shift_y = previous_shift[1] * dimensions[i+1] + world.margin
		
		positional_shift.append([current_shift_x, current_shift_y])
	
	
	# make all the viewports
	var subviewport_0 = main_container
	var id: Array[int] = []
	id.resize(d - 2)
	id.fill(0)
	id[0] = -1
	
	# this is basically kind of combining both CameraBorders script and MineFields script
	# it handles creating odd an even dimensions differently but then will create
	# a dictionary (ID: CAMERA) for the cameras which will ultimately
	# make setting the cameras positions way easier
	for i in range(1, d - 1):# i being the current dimension being worked on (within camera space)
		var old_container = main_container
		
		main_container = GridContainer.new()
		add_child(main_container)
		main_container.size_flags_horizontal = GridContainer.SIZE_EXPAND_FILL
		main_container.size_flags_vertical = GridContainer.SIZE_EXPAND_FILL
		main_container.add_theme_constant_override('h_separation', 0)
		main_container.add_theme_constant_override('v_separation', 0)
		if i % 2 == 1: # odd dimension
			main_container.columns = 3 
			# if it's an even dimension, columns doesn't need to be adjusted
		
		old_container.reparent(main_container)
		for j in range(2): 
			var new_container = old_container.duplicate()
			add_child(new_container)
			new_container.reparent(main_container)
	
	# the scene tree looks something like this with 4d minesweeper
	# there's 9 cameras because we need to see the adjacent up/down left/right
	# TL TM TR
	# ML MM MR
	# BL BM BR
	#
	# if we were to give them coordinates, it turns them into
	#
	# [0, 0] [1, 0] [2, 0]
	# [0, 1] [1, 1] [2, 1]
	# [0, 2] [1, 2] [2, 2]
	#
	# and each camera with such an ID is located at such positions in the tree
	# because of the process used to create the camera configuration and how grid containers are setup
	#
	#CameraContainer (master_container)
	#┖╴@GridContainer@26 (just used to contain all the sub grid containers)
		#┠╴@GridContainer@23 [?, 0]
		#┃  ┠╴SubViewportContainer (the original) [0, 0]
		#┃  ┠╴@SubViewportContainer@24 [1, 0]
		#┃  ┖╴@SubViewportContainer@25 [2, 0]
		#┠╴_GridContainer_23 [?, 1]
		#┃  ┠╴SubViewportContainer [0, 1]
		#┃  ┠╴_SubViewportContainer_24 [1, 1]
		#┃  ┖╴_SubViewportContainer_25 [2, 1]
		#┖╴@GridContainer@27 [?, 2]
			#┠╴SubViewportContainer [0, 2]
			#┠╴_SubViewportContainer_24 [1, 2]
			#┖╴_SubViewportContainer_25 [2, 2]
	#
	# which means a base 3 counter when going from top to bottom is the solution
	#
	#with a 5d board the coordinates of the camera will be [1-3]
	# [0, 0, 0] [1, 0, 0] [2, 0, 0]   [0, 0, 1] [1, 0, 1] [2, 0, 1]   [0, 0, 2] [1, 0, 2] [2, 0, 2]
	# [0, 1, 0] [1, 1, 0] [2, 1, 0]   [0, 1, 1] [1, 1, 1] [2, 1, 1]   [0, 1, 2] [1, 1, 2] [2, 1, 2]
	# [0, 2, 0] [1, 2, 0] [2, 2, 0]   [0, 2, 1] [1, 2, 1] [2, 2, 1]   [0, 2, 2] [1, 2, 2] [2, 2, 2]
	#
	# which should be very familiar to the ID system used for the mines
	#
	#CameraContainer (master container)
		#┖╴@GridContainer@38 
		   #┠╴[?, ?, 0]
		   #┃  ┠╴[?, 0, 0]
		   #┃  ┃  ┠╴[0, 0, 0]
		   #┃  ┃  ┠╴[1, 0, 0]
		   #┃  ┃  ┖╴[2, 0, 0]
		   #┃  ┠╴[?, 1, 0]
		   #┃  ┃  ┠╴[0, 1, 0]
		   #┃  ┃  ┠╴[1, 1, 0]
		   #┃  ┃  ┖╴[2, 1, 0]
		   #┃  ┖╴[?, 2, 0]
		   #┃     ┠╴[0, 2, 0]
		   #┃     ┠╴[1, 2, 0]
		   #┃     ┖╴[1, 2, 0]
		   #┠╴[?, ?, 1]
		   #┃  ┠╴[?, 0, 1]
		   #┃  ┃  ┠╴[0, 0, 1]
		   #┃  ┃  ┠╴[1, 0, 1]
		   #┃  ┃  ┖╴[2, 0, 1]
		   #┃  ┠╴[?, 1, 1]
		   #┃  ┃  ┠╴[0, 1, 1]
		   #┃  ┃  ┠╴[1, 1, 1]
		   #┃  ┃  ┖╴[2, 1, 1]
		   #┃  ┖╴[?, 2, 1]
		   #┃     ┠╴[0, 2, 1]
		   #┃     ┠╴[1, 2, 1]
		   #┃     ┖╴[1, 2, 1]
		   #┖╴[?, ?, 2]
			  #┠╴[?, 0, 2]
			  #┃  ┠╴[0, 0, 2]
			  #┃  ┠╴[1, 0, 2]
			  #┃  ┖╴[2, 0, 2]
			  #┠╴[?, 1, 2]
			  #┃  ┠╴[0, 1, 2]
			  #┃  ┠╴[1, 1, 2]
			  #┃  ┖╴[2, 1, 2]
			  #┖╴[?, 2, 2]
				 #┠╴[0, 2, 2]
				 #┠╴[1, 2, 2]
				 #┖╴[2, 2, 2]
	
	# this also explains how the field is generated since i didn't explain it there
	
	# now borrowing from the  minefield part of the algorithm
	var unvisited = main_container.get_children()
	#keep searching within nested containers to find the viewports
	while len(unvisited) != 0:
		var current = unvisited.pop_front()
		if current is SubViewportContainer:
			# keep track of how many are visited
			var index: int = 0
			id[index] += 1
			
			# base 3 counter more or less
			while id[index] == 3:
				id[index] = 0
				index += 1
				id[index] += 1
			camera_dict[id.duplicate()] = current.get_child(0).get_child(0)
			# while i have it here, i need to do this
			current.get_child(0).world_2d = subviewport_0.get_child(0).world_2d
		else:
			unvisited.append_array(current.get_children())
			
	cameras = get_tree().get_nodes_in_group("cameras") #placeholder to be initialized later
	zoom1 = cameras[0].zoom
	
	
	#shift each camera the required amount
	var temp_arr = [0, 102, 206, 308, 414, 516, 620, 722]
	for i in camera_dict:
		var delta_x = 0
		var delta_y = 0
		for j in range(0, len(i), 2):
			delta_x += i[j] * positional_shift[j / 2][0]
			if j + 1 < len(i):
				delta_y += i[j + 1] * positional_shift[j / 2][1]
		if (delta_x not in temp_arr) and (2 not in i):
			print(i)
			print(Vector2(delta_x, delta_y))
		camera_dict[i].position += Vector2(delta_x, delta_y)
		
	# finally reparent the world
	world.reparent(subviewport_0.get_child(0), true)
	
	# maintain viewport position
	id.fill(1)
	
	var past_position: Vector2 = camera_dict[id].get_global_position()
	print(past_position, id)
	
	var even_dimensions = len(dimensions) / 2 - 1
	var odd_dimensions = (len(dimensions) - 1) / 2
	var viewport_position = Vector2(get_viewport_rect().size.x / (3 ** odd_dimensions) * (3 ** odd_dimensions / 2), get_viewport_rect().size.y / (3 ** even_dimensions) * (3 ** even_dimensions / 2))
	
	#print(past_position)
	var delta = viewport_position + past_position
	
	#for c in cameras:
		#c.position += delta
	# maintain viewport position

func multicam_off():
	# for later
	var id: Array[int] = []
	id.resize(len(dimensions) - 2)
	id.fill(1)
	
	var past_position: Vector2 = camera_dict[id].position
	
	# delete and remove 
	main_container.queue_free()
	for c in cameras:
		c.remove_from_group("cameras")
	
	# setup 1st cam
	main_container = viewport.instantiate()
	
	add_child(main_container)
	self.resized.connect(_on_resized)
	
	main_container.master_container = self
	main_container.subviewport_0 = main_container
	
	world.reparent(main_container.get_child(0))
	
	var camera_dict = {}
	
	cameras = get_tree().get_nodes_in_group("cameras")
	zoom1 = cameras[0].zoom
	
	world.reparent(self)
	
	# maintain middle viewport's view
	
	var even_dimensions = len(dimensions) / 2 - 1
	var odd_dimensions = (len(dimensions) - 1) / 2
	
	var viewport_position = Vector2(get_viewport_rect().size.x / (3 ** odd_dimensions) * (3 ** odd_dimensions / 2), get_viewport_rect().size.y / (3 ** even_dimensions) * (3 ** even_dimensions / 2))
	viewport_position = viewport_position.round()
	cameras[0].position = past_position - viewport_position
	
	
	world.reparent(main_container.get_child(0))

func vector_mod(u, v):
	return Vector2(fposmod(u.x, v.x), fposmod(u.y, v.y))

#func _input(event):
	#multicam_input(event)

# handles moving all cameras at once
func _input(event):
	# Zoom based on cursor position
	# https://www.desmos.com/calculator/b7ufjha1ss
	# I couldn't find anything online that actually helped, so i did the derivation myself

	# regardless of where the mouse actually is, it needs to zoom regardless of which viewport it's on
	# mouse position relative to a single viewport as if it's position was 0,0
	
	# get_global and get_local mouse position will return the same value and returns the position wrt to the main viewport
	# i need it in terms of the coordinate space of the subviewport world and wrt to the top left cameras position
	# so i need to scale the coordinates by the zoom facter, and then add to get it wrt to the camera
	# have a desmos graph, this shows the mouse_position function https://www.desmos.com/calculator/dc7cfi4urn
	var local_mouse_position: Vector2 = get_global_mouse_position() * 1/zoom1 + cameras[0].position
	var mouse_position: Vector2 = cameras[0].position + vector_mod(local_mouse_position - cameras[0].position, cameras[0].get_viewport_rect().size * 1/zoom1)
	
	# vector from the cursor to the corner of the camera, which happens to be just the mouse position
	# because all the math is being done with respect to a camera located at 0, 0
	var d: Vector2 = cameras[0].position - mouse_position
	var zoom2: Vector2 = Vector2.ONE # to be determined later
	
	if event.is_action_pressed('zoom_in'):
		# new zoom amount
		zoom2 = (zoom1.x * sqrt(pa)) * Vector2(1, 1)
		
		# clamp value
		zoom2 = zoom2.clamp(Vector2(1, 1) * zoom_min, Vector2(1, 1) * zoom_max)
		
		# using the formula i derived
		var position2: Vector2 = (mouse_position + d * (zoom1 / zoom2))
		var position_delta: Vector2 = position2 - cameras[0].position
		
		# set all values
		zoom1 = zoom2
		for c in cameras:
			c.zoom = zoom1
			c.position += position_delta
			
	if event.is_action_pressed('zoom_out'):
		# take the reciprocal instead
		zoom2 = (zoom1.x / sqrt(pa)) * Vector2(1, 1)
		zoom2 = zoom2.clamp(Vector2(1, 1) * zoom_min, Vector2(1, 1) * zoom_max)
		var position2: Vector2 = mouse_position + d * (zoom1 / zoom2)
		
		
		# solve for position_delta, this is the position change that's required for all viewports
		var position_delta: Vector2 = position2 - cameras[0].position
		
		# set all values
		zoom1 = zoom2
		for c in cameras:
			c.zoom = zoom1
			c.position += position_delta
			
		print(zoom1)
			
	if event.is_action_pressed("scroll_up", false, true):
		for c in cameras:
			c.position.y -= 24
	if event.is_action_pressed('scroll_down', false, true):
		for c in cameras:
			c.position.y += 24
			
			
	# panning logic
	# referenced
	# https://docs.godotengine.org/en/stable/tutorials/inputs/input_examples.html#mouse-motion
	if event.is_action("pan"):
		# record starting coordinates and start dragging
		if not is_dragging and event.pressed:
			is_dragging = true
			previous_coordinates = event.position
		# Stop dragging if the button is released.
		if is_dragging and not event.pressed:
			is_dragging = false

	# panning
	if event is InputEventMouseMotion and is_dragging:
		# While dragging, move the camera with the mouse
		# drag it in the direction opposite of the way the mouse moved
		# Also scale it by the reciprocal of how much we're zoomed in (if zoomed in further, reduce the amount of movement)
		
		for camera in cameras:
			camera.position += (event.position - previous_coordinates) * -1 * (1 / zoom1.x)
		
		#update the new previous coordinates
		previous_coordinates = event.position
