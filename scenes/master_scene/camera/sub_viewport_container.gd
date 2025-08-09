extends SubViewportContainer

static var subviewport_0 # the original viewport containing the world
static var master_container # the camera container

# Called when the node enters the scene tree for the first time.
func _ready():
	self.resized.connect(_on_resized)
	pass # Replace with function body.
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_resized():
	get_child(0).size = size
	

# This bug is awful
# if cells are off the window and offscreen off the viewports, the world "persists" outside of their contained subviewport
# containers and even the godot window. It would pick up mouse input if it's hovering to the left of the window
# and cells would react, so this means mouse_entered/exit events cant be trusted and i need to write one myself
# for the longest time i thought the subviewport containers were the issue

# cells will not pickup on _input() so inputs being accepted somewhere else and i can't figure
# out how to get that input (to determine when mouse exited)
# so instead i'm going to call up to the MineField node to manage that

# Handles what mouse_entered and mouse_exited would normally do but with the nuance of the multiple viewports
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
