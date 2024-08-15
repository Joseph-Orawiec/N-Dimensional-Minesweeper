extends SubViewportContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	self.resized.connect(_on_resized)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_resized():
	get_child(0).size = size
