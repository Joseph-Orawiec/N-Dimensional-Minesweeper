extends Node

#RR GG BB AA
var colors = {Colors.UNKOWN: Color.hex(0xC7C7C7FF), Colors.PRESSED: Color.hex(0x808080FF)}
enum Colors {UNKOWN, PRESSED}

var red = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	print(colors[Colors.UNKOWN])
	print(colors[Colors.PRESSED])
	print(Color(.1, .2, .3, 1))
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func initialize_red(dimension):
	pass
