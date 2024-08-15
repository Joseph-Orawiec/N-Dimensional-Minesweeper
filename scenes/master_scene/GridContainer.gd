extends GridContainer

@onready var rect = $NinePatchRect

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func initialize(d):
	const dx: int = 1280
	const dy: int = 720
	
	var n = clamp(3 ** (d - 2), 1, INF)
	columns = n
	
	for i in n - 1:
		var rect2 = rect.duplicate()
		add_child(rect2)
