extends GridContainer

var previous_coordinates
var is_dragging
const pa = 1.11 # Area proportionality constant
const zoom_min = .3
const zoom_max = 4

@onready var cameras = get_tree().get_nodes_in_group("cameras")
@onready var zoom1 = cameras[0].zoom

# Called when the node enters the scene tree for the first time.
func _ready():
	var vp1 = $SubViewportContainer/SubViewport
	var vp2 = $SubViewportContainer2/SubViewport2
	
	$SubViewportContainer2/SubViewport2/Camera2D.position = Vector2(640, 0)
	
	
	vp2.world_2d = vp1.world_2d


# Called every frame. 'delta' is the elapsed time since the previous frame.
# mastee
func _process(delta):
	pass
	

func vector_mod(u, v):
	return Vector2(fposmod(u.x, v.x), fposmod(u.y, v.y))

func _input(event):
	# mouse position relative to viewport 
	
	if event.is_action_pressed("m1"):
		print(zoom1)
		for c in cameras:
			print(c.zoom)
	
	var mouse_position = cameras[0].position + vector_mod(get_global_mouse_position() - cameras[0].position, cameras[0].get_viewport_rect().size * 1/zoom1)
	
	# vector from the cursor to the center of the camera
	var d = cameras[0].position - mouse_position
	var zoom2 = 1 # to be determined later
	
	if Input.is_action_just_pressed("m2"):
		print(get_global_mouse_position())
	
	if event.is_action_pressed('zoom_in'):
		
		# new zoom amount
		zoom2 = (zoom1.x * sqrt(pa)) * Vector2(1, 1)
		
		# clamp value
		zoom2 = zoom2.clamp(Vector2(1, 1) * zoom_min, Vector2(1, 1) * zoom_max)
		
		# using the formula i derived
		var position2 = mouse_position + d * (zoom1 / zoom2)
		
		
		
		# solve for position_delta
		var position_delta = position2 - cameras[0].position
		
		print(get_global_mouse_position(), position, d, zoom2)
		print(position2)
		
		# set all values
		zoom1 = zoom2
		for c in cameras:
			print('origin', c.position)
			c.zoom = zoom1
			c.position += position_delta
			print('egh', c.position)
	if event.is_action_pressed('zoom_out'):
		
		# take the reciprocal instead
		zoom2 = (zoom1.x / sqrt(pa)) * Vector2(1, 1)
		zoom2 = zoom2.clamp(Vector2(1, 1) * zoom_min, Vector2(1, 1) * zoom_max)
		var position2 = mouse_position + d * (zoom1 / zoom2)
		
		
		
		# solve for position_delta
		var position_delta = position2 - cameras[0].position
		
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

