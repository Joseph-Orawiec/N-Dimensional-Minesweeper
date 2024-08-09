extends Camera2D

var previous_coordinates
var is_dragging
const pa = 1.11 # Area proportionality constant
const zoom_min = .3
const zoom_max = 9999999999999999

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func vector_mod(u, v):
	return Vector2(fposmod(u.x, v.x), fposmod(u.y, v.y))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	

	if Input.is_key_pressed(KEY_CTRL):
		
		
		var mouse_position = position + vector_mod(get_global_mouse_position() - position, get_viewport_rect().size * 1/zoom)
		#var mouse_position = get_global_mouse_position()
		#var bounds = Rect2(position, get_viewport_rect().size * 1/zoom)
		
		
		# vector from the cursor to the center of the camera
		var d = position - mouse_position
		var zoom2 = 1 # to be determined later
		
		
		
		if Input.is_action_just_pressed("m1"):
			print(get_global_mouse_position(), ' local to camera? ', get_local_mouse_position())
			#print(get_viewport_rect().size)
			print(d)
			
		if Input.is_action_just_pressed("m2"):
			print(get_viewport_rect())
			print(get_global_mouse_position(), ' viewport size ', get_viewport_rect().size * 1/zoom, position)
			print(d)
		
		
		if Input.is_action_just_pressed("scroll_up"):
			
			# zoom by constant screen width growth
			# zoom2 = (zoom * get_viewport().size.x)/(get_viewport().size.x * Vector2(1, 1) - zoom * dx)
			
			# new zoom amount
			zoom2 = (zoom.x * sqrt(pa)) * Vector2(1, 1)
			
			# clamp value
			zoom2 = zoom2.clamp(Vector2(1, 1) * zoom_min, Vector2(1, 1) * zoom_max)
			
			print(get_global_mouse_position(), mouse_position, position, d, zoom2)
			
			# using the formula i derived
			position = mouse_position + d * (zoom / zoom2)
			zoom = zoom2
			
			print(position)
			
		if Input.is_action_just_pressed('scroll_down'):
			# zoom2 = (zoom * get_viewport().size.x)/(get_viewport().size.x * Vector2(1, 1) + zoom * dx)
			
			# take the reciprocal instead
			zoom2 = (zoom.x / sqrt(pa)) * Vector2(1, 1)
			zoom2 = zoom2.clamp(Vector2(1, 1) * zoom_min, Vector2(1, 1) * zoom_max)
			position = mouse_position + d * (zoom / zoom2)
			zoom = zoom2
	else:
		if Input.is_action_just_pressed("scroll_up"):
			position.y -= 24
		if Input.is_action_just_pressed('scroll_down'):
			position.y += 24
	
	# panning logic
	# referenced
	# https://docs.godotengine.org/en/stable/tutorials/inputs/input_examples.html#mouse-motion
	# All cameras need to move, so this had to be moved to polling rather than _input
	if Input.is_action_pressed('pan') or Input.is_action_just_released('pan'):
		# record starting coordinates and start dragging
		if not is_dragging and Input.is_action_pressed('pan'):
			is_dragging = true
			previous_coordinates = get_viewport().get_mouse_position()
		# Stop dragging if the button is released.
		if is_dragging and Input.is_action_just_released('pan'):
			is_dragging = false

	# panning
	if Input.is_action_pressed('pan') and is_dragging:
		# While dragging, move the camera with the mouse
		# drag it in the direction opposite of the way the mouse moved
		# Also scale it by the reciprocal of how much we're zoomed in (if zoomed in further, reduce the amount of movement)
		position += (get_viewport().get_mouse_position() - previous_coordinates) * -1 * (1 / zoom.x)
		
		#update the new previous coordinates
		previous_coordinates = get_viewport().get_mouse_position()
