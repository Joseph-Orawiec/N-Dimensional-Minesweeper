extends SubViewportContainer

var viewport = self.get_child(0)

# Called when the node enters the scene tree for the first time.
func _ready():
	self.resized.connect(_on_resized)
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
		get_parent()._input(event)
		var is_within_x_bounds: bool = (position.x <= event.position.x) and (event.position.x < (position + size).x)
		var is_within_y_bounds: bool = (position.y <= event.position.y) and (event.position.y < (position + size).y)
		
		if (is_within_x_bounds and is_within_y_bounds):
			# shift the event position by the subviewport container and by the camera within the subviewport container
			var camera = get_child(0).get_child(0)
			event.position = (event.position - position) * (1/camera.zoom.x) + camera.position
			get_parent().get_child(0).get_child(0).push_input(event, true)
			#get_child(0).push_input(event)
			if event.is_action_pressed("m1"): 		
				print("SUB ", get_local_mouse_position(), " ", event.position, " ", position)
				print("Subs camera ", get_child(0).get_child(0).position)
		
	
		
	pass
