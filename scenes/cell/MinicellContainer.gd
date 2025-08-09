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

# Called when the node enters the scene tree for the first time.
func _ready():
	
	set_mark(5, 4321)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
# takes in a location 1-9 and then 0-9999
func set_mark(location: int, n: int):
	minicell_dict[location].set_number(n)
