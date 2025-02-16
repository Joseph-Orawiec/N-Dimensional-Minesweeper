extends GridContainer

var previous_coordinates: Vector2
var is_dragging: bool
const pa: float = 1.11 # Area proportionality constant
const zoom_min: float = pow(1.11, -22/2) #roughly .3
const zoom_max: float = pow(1.11, 21/2) #roughly 2.9915

var cameras #placeholder to be initialized later
var zoom1 #placeholder to be initialized later
var camera_array = []

const viewport: PackedScene = preload("res://scenes/master_scene/camera/sub_viewport_container.tscn")

var main_viewport = viewport.instantiate()
var main_subviewport = main_viewport.get_child(0)
var main_camera = main_subviewport.get_child(0)



# Called when the node enters the scene tree for the first time.
func _ready():
	add_child(main_viewport)
	self.resized.connect(_on_resized)
	pass
	
func _on_resized():
	get_child(0).size = size

func initialize(node, dimensions):
	var d: int = len(dimensions)
	
	var n = 3 ** clampi(d - 2, 0, d)
	columns = max(3 ** ((d - 1) / 2), 1)
	
	# array of values in order of how far to shift
	var positional_shift: Array[Array]
	
	# calculate how far each camera needs to be
	var horizontal_cells = dimensions[0] * 50
	var vertical_cells = null
	var horizontal_shift = null
	var vertical_shift = null

	# coding this inductively so i need to setup the base case and all that
	# i would use a try exception block here but that doesnt exist
	if d >= 2:
		vertical_cells = dimensions[1] * 50 
	if d >= 3:
		horizontal_shift = horizontal_cells + node.margin
		
		positional_shift = [[horizontal_shift, 0]] # setups up base case
	if d >= 4:
		vertical_shift = vertical_cells + node.margin
		
		positional_shift[0][1] = vertical_shift # sets up base case, but vertically
	
	# i is for dimensions, but indexed at 0, so starts at the 5th dimension
	# this tackles dimensions 2 at a time and so the base case was the 3rd and 4th dimension
	for i in range(4, d, 2):
		var previous_shift = positional_shift[i/2 - 2]
		var current_shift_x = previous_shift[0] * dimensions[i] + (dimensions[i] - 1) * (i / 2) * node.margin
		# how wide the previous dimension made it * how many times it'll be copies +  margin 
		# the inbetweens (fencepost problem) * how many times the amrgin is repeated 
		
		# repeat above but for veritcally
		var current_shift_y = 0
		if d >= i + 2: # might not be an even dimension, remember i is 0th index dimension so it's +2
			current_shift_x = previous_shift[1] * dimensions[i+1] + (dimensions[i+1] - 1) * (i / 2) * node.margin
		
		positional_shift.append([current_shift_x, current_shift_y])
	
	# shift each camera the required amount
	for i in range(1, n):
		var node2 = main_viewport.duplicate()
		node2.get_child(0).world_2d = main_subviewport.world_2d
		
		node2.get_child(0).get_child(0).position = main_camera.position + Vector2(positional_shift[0][0] * (i % 3), positional_shift[0][1] * (i / 3))
		add_child(node2)
		
	print(positional_shift)
	
	cameras = get_tree().get_nodes_in_group("cameras") #placeholder to be initialized later
	zoom1 = cameras[0].zoom
	node.reparent(main_subviewport, true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
# mastee
func _process(delta):
	pass
	

func vector_mod(u, v):
	return Vector2(fposmod(u.x, v.x), fposmod(u.y, v.y))

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
