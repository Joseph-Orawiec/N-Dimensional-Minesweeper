extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	
	var node = preload("res://scenes/cell/cell.tscn")
	
	#for y in 10:
		#for x in 10:
			#var temp = node.instantiate()
			#temp.position.x = x * 50
			#temp.position.y = y * 50
			#add_child(temp)
			
			
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
# I could have made an N-dimensional vector class but this is the only method i really need
func add(u):
	# only accept numbers and other vectors
	assert((u is Array) or (u is int) or (u is float))
	
	var arr = []
	match typeof(u):
		TYPE_FLOAT, TYPE_INT:
			for i in range(len(self.v)):
				arr.append(self.v[i] + u)
			
		TYPE_ARRAY:
			assert(len(self.v) == len(u.v))
			
			for i in range(len(self.v)):
				arr.append(self.v[i] + u.v[i])
			
	return arr
