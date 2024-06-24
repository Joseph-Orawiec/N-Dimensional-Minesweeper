extends GridContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	var vp1 = $SubViewportContainer/SubViewport
	var vp2 = $SubViewportContainer2/SubViewport2
	
	$SubViewportContainer2/SubViewport2/Camera2D.position = Vector2(640, 0)
	
	vp2.world_2d = vp1.world_2d


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
