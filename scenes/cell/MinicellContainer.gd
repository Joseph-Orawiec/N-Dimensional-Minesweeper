extends Control



@onready var minicell_dict = {
	1: $"1",
	2: $"2",
	3: $"3",
	4: $"4",
	5: $"5",
	6: $"6",
	7: $"7",
	8: $"8",
	9: $"9",
}

# dictionary of whether each minicell is marked or not
var minicell_mark_dict = {
	1: false,
	2: false,
	3: false,
	4: false,
	5: false,
	6: false,
	7: false,
	8: false,
	9: false,
}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
# takes in a location 1-9 and then 0-9999
func set_mark(location: int, n: int):
	minicell_dict[location].set_number(n)
	
	if n == 0:
		minicell_mark_dict[location] = true
	else:
		minicell_mark_dict[location] = false

func reset():
	for i in minicell_dict.keys():
		minicell_dict[i].set_number(0)
		minicell_mark_dict[i] = false
