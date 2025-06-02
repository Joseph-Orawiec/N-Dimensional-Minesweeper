extends SubViewportContainer

static var subviewport_0 # the original viewport containing the world
static var master_container # the camera container

# Called when the node enters the scene tree for the first time.
func _ready():
	self.resized.connect(_on_resized)
	
	print(master_container, "master_container")
	pass # Replace with function body.
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_resized():
	get_child(0).size = size
	
func _input(event):
	#inclusive on 0, exclusive on 720
	#[0, size.y - 1]
	if event is InputEventMouseButton or event is InputEventMouseMotion:
		var is_within_x_bounds: bool = (get_global_position().x <= event.position.x) and (event.position.x < (get_global_position() + size).x)
		var is_within_y_bounds: bool = (get_global_position().y <= event.position.y) and (event.position.y < (get_global_position() + size).y)
		
		if (is_within_x_bounds and is_within_y_bounds):
			# passes input to handle camera related logic
			master_container._input(event)
			
			# shift the event position by the subviewport container and by the camera within the subviewport container
			var camera = self.get_child(0).get_child(0)
			event.position = (event.position - get_global_position()) * (1/camera.zoom.x) + camera.position
			
			# passes input to handle game logic
			subviewport_0.get_child(0).push_input(event, false)
