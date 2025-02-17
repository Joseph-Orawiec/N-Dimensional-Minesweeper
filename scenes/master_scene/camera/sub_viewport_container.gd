extends SubViewportContainer

var subviewport_0
var master_container

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
		var is_within_x_bounds: bool = (get_global_position().x <= event.position.x) and (event.position.x < (get_global_position() + size).x)
		var is_within_y_bounds: bool = (get_global_position().y <= event.position.y) and (event.position.y < (get_global_position() + size).y)
		
		if (is_within_x_bounds and is_within_y_bounds):
			if event.is_action_pressed("m1"): 		
				print("SUB ", get_local_mouse_position(), " ", event.position, " ", position, get_global_position())
				print("Subs camera ", get_child(0).get_child(0).position)
			master_container._input(event)
			# shift the event position by the subviewport container and by the camera within the subviewport container
			var camera = self.get_child(0).get_child(0)
			event.position = (event.position - get_global_position()) * (1/camera.zoom.x) + camera.position
			#event.position = event.position * (1/camera.zoom.x) + camera.position
			subviewport_0.get_child(0).push_input(event, false)
			#get_child(0).push_input(event)
			
			if event.is_action_pressed("m1"): 		
				print("SUB post process ", get_local_mouse_position(), " ", event.position, " ", position)
			
		
	
		
	pass
