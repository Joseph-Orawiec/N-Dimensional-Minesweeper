extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	
	var node = preload("res://scenes/cell/cell.tscn")
	
	for y in 10:
		for x in 10:
			var temp = node.instantiate()
			temp.position.x = x * 50
			temp.position.y = y * 50
			add_child(temp)
			
			
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
